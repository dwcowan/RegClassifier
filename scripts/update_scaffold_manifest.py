#!/usr/bin/env python3
import argparse, json, os, sys, hashlib
from pathlib import Path
import fnmatch

def sha256_file(p: Path) -> str:
    h = hashlib.sha256()
    with p.open('rb') as f:
        for chunk in iter(lambda: f.read(65536), b''):
            h.update(chunk)
    return h.hexdigest()

def match_any(path: str, patterns):
    return any(fnmatch.fnmatch(path, pat) for pat in patterns)

def bump_semver(ver: str):
    parts = ver.split(".")
    if len(parts) != 3: return "1.0.0"
    major, minor, patch = map(int, parts)
    patch += 1
    return f"{major}.{minor}.{patch}"

def main():
    parser = argparse.ArgumentParser(description="Update scaffold_manifest.json (SHA256 + size + versions).")
    parser.add_argument("--manifest", default="scaffold_manifest.json")
    parser.add_argument("--bump", default="", help="bump=all or bump=file:<path>")
    args = parser.parse_args()

    repo = Path(".").resolve()
    manifest_path = repo / args.manifest
    if not manifest_path.exists():
        print(f"[ERR] Manifest not found: {manifest_path}", file=sys.stderr)
        return 1

    data = json.loads(manifest_path.read_text(encoding='utf-8'))
    include = data.get("include", [])
    exclude = data.get("exclude", [])
    old_files = { f["path"]: f for f in data.get("files", []) }

    all_paths = []
    for root, dirs, files in os.walk(repo):
        rel_root = os.path.relpath(root, repo)
        if rel_root == ".": rel_root = ""
        for fname in files:
            rel = os.path.join(rel_root, fname) if rel_root else fname
            rel = rel.replace("\\", "/")
            if include and not match_any(rel, include): 
                continue
            if exclude and match_any(rel, exclude): 
                continue
            all_paths.append(rel)

    files_out = []
    for rel in sorted(all_paths):
        p = repo / rel
        entry = {
            "path": rel,
            "sha256": sha256_file(p),
            "size": p.stat().st_size,
            "ver": old_files.get(rel, {}).get("ver", "1.0.0"),
            "mode": old_files.get(rel, {}).get("mode", "any"),
            "notes": old_files.get(rel, {}).get("notes", "")
        }
        files_out.append(entry)

    bump = args.bump.strip()
    if bump == "all":
        data["scaffoldVersion"] = bump_semver(str(data.get("scaffoldVersion","1.0.0")))
    elif bump.startswith("file:"):
        target = bump[len("file:"):]
        for f in files_out:
            if f["path"] == target:
                f["ver"] = bump_semver(f["ver"])

    data["files"] = files_out
    manifest_path.write_text(json.dumps(data, indent=2), encoding='utf-8')
    print(f"[OK] Updated {manifest_path} with {len(files_out)} files.")

if __name__ == "__main__":
    sys.exit(main())
