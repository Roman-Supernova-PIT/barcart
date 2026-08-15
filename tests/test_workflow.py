from snappl.diaobject import DiaObject

from barcart.workflow import run_workflow


def test_run_workflow_returns_candidate_list() -> None:
    candidates = run_workflow(input_path="demo.csv", output_dir="tmp_out")

    assert len(candidates) == 1
    assert isinstance(candidates[0], DiaObject)
    assert candidates[0].name == "cand-001"
    assert candidates[0].properties["source"] == "sidecar"
