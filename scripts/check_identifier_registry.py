#!/usr/bin/env python3
"""Verify MATLAB identifiers against the registry.

This script scans all ``.m`` files for the primary function or class name
and ensures each identifier appears in ``docs/identifier_registry.md``.
If any identifier is missing from the registry, the script exits with a
non-zero status and lists the missing names.
"""
from __future__ import annotations

import re
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]
REGISTRY_PATH = ROOT / "docs" / "identifier_registry.md"


def extract_primary_identifier(path: Path) -> str | None:
    """Return the first function or class name found in a MATLAB file.

    Only the first top-level ``function`` or ``classdef`` statement is
    considered. Local functions defined later in the file are ignored.
    """
    pattern_func = re.compile(
        r"^function\s+(?:\[[^\]]*\]\s*=\s*|[a-zA-Z]\w*\s*=\s*)?([a-zA-Z]\w*)"
    )
    pattern_class = re.compile(r"^classdef\s+([a-zA-Z]\w*)")

    with path.open() as fh:
        for line in fh:
            line = line.strip()
            if line.startswith("%") or not line:
                continue
            m_func = pattern_func.match(line)
            if m_func:
                return m_func.group(1)
            m_class = pattern_class.match(line)
            if m_class:
                return m_class.group(1)
            # Stop scanning if we encounter executable code before a definition.
            if not line.startswith(('function', 'classdef', '%')):
                break
    return None


def parse_registry(path: Path) -> set[str]:
    """Parse the identifier registry and return documented names."""
    names: set[str] = set()
    section = None
    valid_sections = {"classes", "functions", "tests"}
    with path.open() as fh:
        for raw_line in fh:
            line = raw_line.strip()
            if line.lower().startswith("## classes"):
                section = "classes"
                continue
            if line.lower().startswith("## functions"):
                section = "functions"
                continue
            if line.lower().startswith("## tests"):
                section = "tests"
                continue
            if line.startswith("## "):
                section = None
                continue
            if section in valid_sections and line.startswith("|"):
                cells = [c.strip() for c in line.strip("|").split("|")]
                if cells and cells[0] not in ("Name", "") and not set(cells[0]) <= {"-"}:
                    names.add(cells[0])
    return names


def main() -> int:
    if not REGISTRY_PATH.is_file():
        print(f"Registry file not found: {REGISTRY_PATH}", file=sys.stderr)
        return 1

    documented = parse_registry(REGISTRY_PATH)

    found = {}
    for path in ROOT.rglob("*.m"):
        ident = extract_primary_identifier(path)
        if ident:
            found[ident] = path

    missing = sorted(set(found) - documented)
    if missing:
        print("The following identifiers are missing from docs/identifier_registry.md:")
        for name in missing:
            print(f"  - {name} (defined in {found[name]})")
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
