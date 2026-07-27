"""CLI do núcleo experimental BRX."""

from __future__ import annotations

import argparse
import json
from pathlib import Path
import sys

from .core import BRXError, Runtime, compile_source


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(prog="brxbase", description="Compilador BRX para BRX-IR")
    parser.add_argument("arquivo", type=Path, help="arquivo-fonte .brx")
    parser.add_argument("--emit-ir", action="store_true", help="exibe a BRX-IR em JSON")
    parser.add_argument("--run", action="store_true", help="executa a IR após compilar")
    return parser


def main(argv: list[str] | None = None) -> int:
    args = build_parser().parse_args(argv)
    try:
        source = args.arquivo.read_text(encoding="utf-8")
        module = compile_source(source, args.arquivo.stem)
        if args.emit_ir:
            print(module.to_json())
        if args.run:
            result = Runtime().execute(module)
            for line in result["output"]:
                print(line)
            if result["return"] is not None:
                print(json.dumps({"return": result["return"]}, ensure_ascii=False))
        if not args.emit_ir and not args.run:
            print(f"OK: {args.arquivo} -> BRX-IR v{module.version}")
        return 0
    except (OSError, BRXError) as exc:
        print(f"erro: {exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
