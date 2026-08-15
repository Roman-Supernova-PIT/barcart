from pathlib import Path

from astropy.table import Table

from barcart.detection_parser import parse_sidecar_detection


def test_parse_sidecar_detection() -> None:
    path = Path("tmp_score_detection.ecsv")
    table = Table(
        {
            "id": ["candidate_1", "candidate_2", "candidate_3", "candidate_4"],
            "x_peak": [0, 0, 0, 1],
            "y_peak": [0, 0, 0, 2],
            "peak_value": [0, 0, 0, 3],
            "x_centroid": [0, 0, 0, 4],
            "y_centroid": [0, 0, 0, 5],
            "ra": [0, 0, 0, 6],
            "dec": [0, 0, 0, 7],
        }
    )
    table.write(path, format="ascii.ecsv", overwrite=True)

    try:
        assert parse_sidecar_detection(path) == ("candidate_4", "6", "7")
    finally:
        path.unlink(missing_ok=True)
