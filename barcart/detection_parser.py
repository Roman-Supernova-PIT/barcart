from __future__ import annotations

import argparse
from pathlib import Path
from typing import Sequence

from astropy.table import Table


def parse_sidecar_detection(path: str | Path, row_idx: int = -1) -> tuple[int, float, float]:
    """Return the detection id, RA, and DEC from the relevant sidecar row.

    The score-detection catalog is stored as an ECSV table with named columns,
    so we read it via Astropy and retrieve the values by column names instead of
    assuming a fixed column ordering.

    path: str | Path
        The path to the score-detection catalog ECSV file.
    row_idx: int
        The index of the row to retrieve. Defaults to -1, which is the last row.
    """
    score_file = Path(path)
    table = Table.read(score_file, format="ascii.ecsv")

    required_columns = {"id", "ra", "dec"}
    missing = sorted(required_columns - set(table.colnames))
    if missing:
        raise ValueError(f"Missing required columns in {score_file!s}: {missing}")

    row = table[row_idx]
    detection_id = int(row["id"])
    ra = float(row["ra"])
    dec = float(row["dec"])
    return detection_id, ra, dec


def main(argv: Sequence[str] | None = None) -> int:
    """CLI for extracting detection id, RA, and DEC from a sidecar score file."""
    parser = argparse.ArgumentParser(
        description="Extract detection id, RA, and DEC from a sidecar score ECSV file."
    )
    parser.add_argument("path", help="Path to score_detection_*.ecsv")
    parser.add_argument(
        "--row-idx",
        type=int,
        default=-1,
        help="Row index to read (default: -1, the last row).",
    )
    args = parser.parse_args(argv)

    detection_id, ra, dec = parse_sidecar_detection(args.path, row_idx=args.row_idx)
    print(f"{detection_id} {ra} {dec}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
