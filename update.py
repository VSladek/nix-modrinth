#!/usr/bin/env nix-shell
#!nix-shell -i python3 -p python3Packages.requests
"""
Refreshes mods/<loader>/<name>.json from catalog.nix + the Modrinth API.
Requires `nix` itself to already be on PATH (used to evaluate catalog.nix).

Modrinth's version-list endpoint returns the full history plus hashes in one
call, so each run fully rebuilds a mod's lock file from scratch rather than
incrementally patching it in place -- there's no expensive per-version fetch
to avoid repeating, and rebuilding from scratch sidesteps stale entries left
over by a previous catalog.nix edit (e.g. a mod's `loaders` list changing).

Usage:
  ./update.py                  # refresh every mod/loader in catalog.nix
  ./update.py --only lithium   # refresh a single mod
  ./update.py --check          # print what would change, without writing anything
"""

import argparse
import json
import subprocess
import sys
from pathlib import Path

import requests

ROOT = Path(__file__).parent
MODS_DIR = ROOT / "mods"
CATALOG = ROOT / "catalog.nix"
API = "https://api.modrinth.com/v2"
USER_AGENT = "nix-modrinth/1.0 (https://github.com/; generator script, not the game client)"


def load_catalog():
    result = subprocess.run(
        ["nix", "eval", "--json", "--file", str(CATALOG)],
        capture_output=True,
        text=True,
    )
    if result.returncode != 0:
        sys.exit(f"failed to evaluate {CATALOG}:\n{result.stderr}")
    return json.loads(result.stdout)


def fetch_versions(project, loader):
    resp = requests.get(
        f"{API}/project/{project}/version",
        params={"loaders": json.dumps([loader])},
        headers={"User-Agent": USER_AGENT},
        timeout=30,
    )
    resp.raise_for_status()
    return resp.json()


def lock_entry(version):
    files = version["files"]
    primary = next((f for f in files if f.get("primary")), files[0])
    return {
        "versionId": version["id"],
        "gameVersions": version["game_versions"],
        "versionType": version["version_type"],
        "datePublished": version["date_published"],
        "filename": primary["filename"],
        "url": primary["url"],
        "sha512": primary["hashes"]["sha512"],
    }


def lock_key(version, version_number_counts):
    # version_number is usually unique within a project, but plenty of mods
    # republish the same string for separate releases (e.g. one build per
    # game version, string not bumped). Only disambiguate with the version
    # id when it's actually needed, so the common case stays readable.
    number = version["version_number"]
    if version_number_counts[number] > 1:
        return f"{number}-{version['id']}"
    return number


def update_mod(name, project, loader, check):
    lock_path = MODS_DIR / loader / f"{name}.json"
    existing = json.loads(lock_path.read_text()) if lock_path.exists() else {}

    versions = fetch_versions(project, loader)

    counts = {}
    for version in versions:
        counts[version["version_number"]] = counts.get(version["version_number"], 0) + 1

    updated = {}
    for version in versions:
        updated[lock_key(version, counts)] = lock_entry(version)
    updated = dict(sorted(updated.items()))

    if updated == existing:
        print(f"{loader}/{name}: up to date ({len(existing)} versions)")
        return

    added = updated.keys() - existing.keys()
    removed = existing.keys() - updated.keys()
    print(
        f"{loader}/{name}: {len(updated)} versions "
        f"(+{len(added)}{f' -{len(removed)}' if removed else ''})"
    )
    if check:
        return

    lock_path.parent.mkdir(parents=True, exist_ok=True)
    lock_path.write_text(json.dumps(updated, indent=2) + "\n")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--only", help="only refresh this mod name from catalog.nix")
    parser.add_argument(
        "--check", action="store_true", help="report what would change without writing"
    )
    args = parser.parse_args()

    catalog = load_catalog()
    if args.only:
        if args.only not in catalog:
            sys.exit(f"{args.only!r} is not in catalog.nix")
        catalog = {args.only: catalog[args.only]}

    for name, meta in catalog.items():
        for loader in meta["loaders"]:
            update_mod(name, meta["project"], loader, args.check)


if __name__ == "__main__":
    main()
