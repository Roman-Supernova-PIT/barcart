from pathlib import Path

from astropy.table import Column, Table

from barcart.detection_parser import main, parse_sidecar_detection


def test_parse_sidecar_detection() -> None:
    path = Path("tmp_score_detection.ecsv")
    table = Table(
        {
            "id": Column([1, 2, 3, 4], dtype=int),
            "x_peak": Column([0.0, 0.0, 0.0, 1.0], dtype=float),
            "y_peak": Column([0.0, 0.0, 0.0, 2.0], dtype=float),
            "peak_value": Column([0.0, 0.0, 0.0, 3.0], dtype=float),
            "x_centroid": Column([0.0, 0.0, 0.0, 4.0], dtype=float),
            "y_centroid": Column([0.0, 0.0, 0.0, 5.0], dtype=float),
            "ra": Column([0.0, 0.0, 0.0, 6.0], dtype=float),
            "dec": Column([0.0, 0.0, 0.0, 7.0], dtype=float),
        }
    )
    table.write(path, format="ascii.ecsv", overwrite=True)

    try:
        assert parse_sidecar_detection(path) == (4, 6.0, 7.0)
    finally:
        path.unlink(missing_ok=True)


def test_detection_parser_main_prints_values(capsys) -> None:
    path = Path("tmp_score_detection.ecsv")
    table = Table(
        {
            "id": [1, 2],
            "ra": [11.1, 22.2],
            "dec": [-33.3, -44.4],
        }
    )
    table.write(path, format="ascii.ecsv", overwrite=True)

    try:
        exit_code = main([str(path)])
        captured = capsys.readouterr()
        assert exit_code == 0
        assert captured.out.strip() == "2 22.2 -44.4"
    finally:
        path.unlink(missing_ok=True)
