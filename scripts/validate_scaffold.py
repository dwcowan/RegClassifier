#!/usr/bin/env python3
"""Validate that stub modules and tests listed in docs/master_scaffold.md exist."""

from __future__ import annotations

import re
import sys
from pathlib import Path


def main() -> int:
    repo_root = Path(__file__).resolve().parent.parent
    scaffold = repo_root / "docs" / "master_scaffold.md"
    text = scaffold.read_text(encoding="utf-8")

    stub_paths = set(re.findall(r"`(\+reg/[^`]+)`", text))
    test_paths = set(re.findall(r"`(tests/[^`]+)`", text))

    missing: list[str] = []
    for rel in sorted(stub_paths.union(test_paths)):
        if not (repo_root / rel).exists():
            missing.append(rel)

    if missing:
        for path in missing:
            print(f"Missing expected file: {path}", file=sys.stderr)
        return 1

    print("All scaffold files are present.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
