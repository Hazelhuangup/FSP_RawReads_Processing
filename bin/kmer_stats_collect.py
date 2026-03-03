#!/usr/bin/env python3
"""Collect k-mer statistics from logs and peak summaries."""

from __future__ import annotations

import argparse
import csv
import re
from pathlib import Path


COLUMNS = [
    "Seq_ID",
    "peak_count",
    "peak_positions",
    "total_kmers",
    "unique_kmers",
    "peak1_kcov",
    "peak1_est_genome_size(len)",
    "peak2_kcov",
    "peak2_est_genome_size(len)",
    "peak1_model_fit_min",
    "peak1_model_fit_max",
    "peak2_model_fit_min",
    "peak2_model_fit_max",
]


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Collect k-mer statistics into a CSV file."
    )
    parser.add_argument("--input-dir", required=True, help="Base input directory")
    parser.add_argument("--peak-csv", required=True, help="Peak classification CSV path")
    parser.add_argument("--out-csv", required=True, help="Output CSV path")
    return parser.parse_args()


def ensure(data: dict[str, dict[str, str]], sample_id: str) -> dict[str, str]:
    return data.setdefault(sample_id, {"Seq_ID": sample_id})


def extract_value(line: str) -> str:
    if ":" in line:
        return line.split(":", 1)[1].strip()
    return line.strip()


def parse_kcov_len(text: str) -> tuple[str, str]:
    if not text:
        return "", ""
    kcov_match = re.search(r"kcov:\s*([0-9.eE+-]+)", text)
    len_match = re.search(r"len:\s*([0-9.eE+-]+)", text)
    kcov_value = kcov_match.group(1) if kcov_match else ""
    len_value = len_match.group(1) if len_match else ""
    return kcov_value, len_value


def parse_model_fit(text: str) -> tuple[str, str]:
    if not text:
        return "", ""
    values = re.findall(r"[0-9]+(?:\.[0-9]+)?", text)
    if len(values) >= 2:
        return values[0], values[1]
    if len(values) == 1:
        return values[0], ""
    return "", ""


def main() -> None:
    args = parse_args()
    input_dir = Path(args.input_dir)
    peak_csv = Path(args.peak_csv)
    out_csv = Path(args.out_csv)

    data: dict[str, dict[str, str]] = {}

    if peak_csv.exists():
        with peak_csv.open(newline="") as fh:
            reader = csv.DictReader(fh)
            for row in reader:
                sample_id = row.get("sample_id", "").strip()
                if not sample_id:
                    continue
                entry = ensure(data, sample_id)
                entry["peak_count"] = row.get("peak_count", "")
                entry["peak_positions"] = row.get("peak_positions", "")

    for log_path in input_dir.glob("*/*.log"):
        sample_id = log_path.parent.name
        entry = ensure(data, sample_id)
        lines = log_path.read_text(errors="ignore").splitlines()
        for line in lines:
            if "Total no. of k-mers" in line:
                entry["total_kmers"] = extract_value(line)
            elif "No. of unique k-mers" in line:
                entry["unique_kmers"] = extract_value(line)
        if len(lines) >= 2:
            value = extract_value(lines[-2])
            kcov_value, len_value = parse_kcov_len(value)
            entry["peak2_kcov"] = kcov_value
            entry["peak2_est_genome_size(len)"] = len_value
        if len(lines) >= 5:
            value = extract_value(lines[-5])
            kcov_value, len_value = parse_kcov_len(value)
            entry["peak1_kcov"] = kcov_value
            entry["peak1_est_genome_size(len)"] = len_value

    for summary_path in input_dir.glob("*/peak_1/summary.txt"):
        sample_id = summary_path.parents[1].name
        entry = ensure(data, sample_id)
        for line in summary_path.read_text(errors="ignore").splitlines():
            if "Model Fit" in line:
                value = extract_value(line)
                min_value, max_value = parse_model_fit(value)
                entry["peak1_model_fit_min"] = min_value
                entry["peak1_model_fit_max"] = max_value
                break

    for summary_path in input_dir.glob("*/peak_2/summary.txt"):
        sample_id = summary_path.parents[1].name
        entry = ensure(data, sample_id)
        for line in summary_path.read_text(errors="ignore").splitlines():
            if "Model Fit" in line:
                value = extract_value(line)
                min_value, max_value = parse_model_fit(value)
                entry["peak2_model_fit_min"] = min_value
                entry["peak2_model_fit_max"] = max_value
                break

    out_csv.parent.mkdir(parents=True, exist_ok=True)
    with out_csv.open("w", newline="") as fh:
        writer = csv.DictWriter(fh, fieldnames=COLUMNS)
        writer.writeheader()
        for sample_id in sorted(data):
            writer.writerow({col: data[sample_id].get(col, "") for col in COLUMNS})

    print(f"Wrote {out_csv}")


if __name__ == "__main__":
    main()
