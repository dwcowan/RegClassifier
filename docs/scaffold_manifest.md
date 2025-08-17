# Scaffold Manifest & Versioning

Track the scaffold files and detect drift with cryptographic hashes.

## Files
- `scaffold_manifest.json` — configuration + inventory (hashes/sizes/versions).
- `scaffold_manifest.schema.json` — optional schema for validation.
- `scripts/update_scaffold_manifest.py` — expands globs, computes SHA256, bumps versions.

## Use
```bash
python3 scripts/update_scaffold_manifest.py
# bump whole scaffold
python3 scripts/update_scaffold_manifest.py --bump all
# bump one file
python3 scripts/update_scaffold_manifest.py --bump file:tools/check_style.m
```
Commit the updated `scaffold_manifest.json` with your changes.

## CI Idea
Add a job that runs the updater and fails if the manifest changes (uncommitted drift).

