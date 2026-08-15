from __future__ import annotations

from pathlib import Path

from astropy.table import Table


def parse_sidecar_detection(path: str | Path, row_idx=-1) -> tuple[str, str, str]:
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
    detection_id = str(row["id"])
    ra = str(row["ra"])
    dec = str(row["dec"])
    return detection_id, ra, dec
