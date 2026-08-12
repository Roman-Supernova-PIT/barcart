from snappl.config import Config


def test_config_reads_dotted_fields(tmp_path) -> None:
    config_path = tmp_path / "barcart.yaml"
    config_path.write_text(
        "workflow:\n"
        "  input: demo.csv\n"
        "  output_dir: outputs\n",
        encoding="utf-8",
    )

    config = Config.get(str(config_path), setdefault=False, static=False)

    assert config.value("workflow.input") == "demo.csv"
    assert config.value("workflow.output_dir") == "outputs"
