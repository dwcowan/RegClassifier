#!/usr/bin/env python3
"""Fail if .m module files change without corresponding tests."""
import subprocess
import sys
from pathlib import Path


def get_staged_files():
    proc = subprocess.run(
        ["git", "diff", "--cached", "--name-only"],
        capture_output=True,
        text=True,
        check=False,
    )
    if proc.returncode != 0:
        print("Failed to obtain staged files", file=sys.stderr)
        return []
    return [Path(p) for p in proc.stdout.splitlines() if p]


def main() -> int:
    files = get_staged_files()
    if not files:
        return 0
    code_changes = [f for f in files if f.suffix == ".m" and not str(f).startswith("tests/")]
    test_changes = [f for f in files if str(f).startswith("tests/") and f.suffix == ".m"]
    if code_changes and not test_changes:
        print("Error: module changes detected without corresponding tests:")
        for f in code_changes:
            print(f"  {f}")
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
