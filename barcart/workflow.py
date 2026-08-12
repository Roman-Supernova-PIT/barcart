from __future__ import annotations

from pathlib import Path
from typing import List

from snappl.diaobject import DiaObject


def run_workflow(input_path: str | None = None, output_dir: str | None = None) -> List[DiaObject]:
    """Placeholder workflow that creates a simple candidate list."""
    input_path = input_path or "input.csv"
    output_dir = output_dir or "outputs"

    Path(output_dir).mkdir(parents=True, exist_ok=True)

    candidates = [
        DiaObject(
            ra=10.0,
            dec=20.0,
            name="cand-001",
            properties={"band": "F106", "observation_id": "obs-1", "score": 0.95, "source": "sidecar"},
        ),
    ]

    if input_path:
        Path(output_dir, "candidates.json").write_text(
            f"Workflow input: {input_path}\\nCandidates: {len(candidates)}\\n",
            encoding="utf-8",
        )

    return candidates
