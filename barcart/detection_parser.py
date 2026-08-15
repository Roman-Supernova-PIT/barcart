from __future__ import annotations

from pathlib import Path


def parse_sidecar_detection(path: str | Path) -> tuple[str, str, str]:
    """Return the detection id, RA, and DEC from the relevant sidecar row.

    The ECSV file includes comment lines and a header, then a sequence of rows.
    We skip comment/blank lines and read the first non-comment row that contains
    the ID, RA, and DEC fields in the expected column positions.
    """
    score_file = Path(path)
    rows: list[str] = []

    with score_file.open("r", encoding="utf-8") as fh:
        for line in fh:
            if line.startswith("#") or not line.strip():
                continue
            rows.append(line.strip())

    if len(rows) < 4:
        raise ValueError(f"Not enough data rows in {score_file!s}; found {len(rows)}")

    parts = rows[3].split()
    if len(parts) < 8:
        raise ValueError(
            f"Expected at least 8 whitespace-separated columns in {score_file!s}, got {len(parts)}: {rows[3]!r}"
        )

    detection_id, ra, dec = parts[0], parts[6], parts[7]
    return detection_id, ra, dec
