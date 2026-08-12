from __future__ import annotations

import argparse

from snappl.config import Config

from .workflow import run_workflow


def main() -> None:
    parser = argparse.ArgumentParser(prog="barcart")
    parser.add_argument("--config", default=None)
    parser.add_argument("--input", default=None)
    parser.add_argument("--output-dir", default=None)
    args = parser.parse_args()

    config = Config.get(args.config, setdefault=bool(args.config), static=False) if args.config else None

    input_path = args.input
    output_dir = args.output_dir
    if config is not None:
        if input_path is None:
            input_path = config.value("workflow.input")
        if output_dir is None:
            output_dir = config.value("workflow.output_dir")

    candidates = run_workflow(input_path=input_path, output_dir=output_dir)
    print(f"Produced {len(candidates)} candidate(s)")
    for candidate in candidates:
        print(candidate)


if __name__ == "__main__":
    main()
