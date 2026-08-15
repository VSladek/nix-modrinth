# nix-modrinth

A generated, versioned database of Modrinth mods for Nix, in the style of
[nix-minecraft](https://github.com/Infinidoge/nix-minecraft)'s server package
sets (`fabricServers`, `paperServers`, ...): a hand-maintained catalog of
which projects to track, a Python script that locks every published version's
URL and hash from the Modrinth API, and a `default.nix` that turns the lock
files into real derivations.

## Layout

- `catalog.nix` — hand-maintained registry: which Modrinth project IDs to
  track, and for which loaders. Edit this to add/remove a mod.
- `mods/<loader>/<name>.json` — **generated**, do not hand-edit. Every version
  Modrinth has published for that mod/loader, keyed by version string, with
  `{ versionId, gameVersions, versionType, datePublished, filename, url, sha512 }`.
- `update.py` — regenerates the lock files from `catalog.nix` + the Modrinth API.
- `default.nix` / `lib/` — build the `modrinthMods` attrset from the above.

## Usage

Add a mod: add an entry to `catalog.nix` with its Modrinth project ID and
which loaders to track, then run:

```console
./update.py                  # refresh every mod in catalog.nix
./update.py --only lithium   # refresh just one
./update.py --check          # dry run — show what would change
```

(Requires `nix` on `PATH`; everything else is pulled in via the script's
`nix-shell` shebang.)

`.github/workflows/update-mods.yml` runs the same script weekly and opens a PR
with whatever changed in `mods/` — review the diff before merging, since a
mod moving to a new version changes what `.latest`/`.byGameVersion` resolve to
for every consumer. Only takes effect once this repo is pushed to GitHub.

Consume from another flake:

```nix
{
  inputs.nix-modrinth.url = "path:/home/vojta/Projects/nix-modrinth"; # or a git remote
  # ...
  nixpkgs.overlays = [ inputs.nix-modrinth.overlay ];
}
```

Then, in a NixOS module:

```nix
# newest build compatible with a given game version — mirrors nix-minecraft's
# `fabricServers.fabric-1_21_10` style
pkgs.modrinthMods.fabric."1_21_10".lithium

# newest version tracked at all, regardless of game version
pkgs.modrinthMods.fabric.latest.lithium

# an exact, specific version — the escaped Modrinth version string
pkgs.modrinthMods.fabric.byVersion.lithium."0_19_0-mc1_21_9"

# select explicitly from the set — don't `builtins.attrValues` the whole
# thing, or every tracked mod compatible with that game version ships,
# not just the ones you actually want
symlinks.mods = pkgs.linkFarmFromDrvs "mods" (
  with pkgs.modrinthMods.fabric."1_21_10";
  [
    lithium
    fabric-api
  ]
);
```

## Out of scope

Mods not hosted on Modrinth (e.g. `fabric-carpet`, which ships GitHub
releases) aren't tracked here — they stay a plain `pkgs.fetchurl` in the
consuming flake. Datapacks (VanillaTweaks and similar) are a different system
entirely and are also out of scope.

## Notes

- "Latest" is resolved by `datePublished`, not by parsing the mod's own
  version string — mod authors don't follow a consistent version scheme the
  way Mojang/Fabric game/loader versions do.
- A mod's `version_number` is assumed unique per project, but some authors
  reuse the same string across releases (e.g. one build per game version,
  string not bumped). `update.py` detects this and disambiguates the lock key
  by appending the Modrinth version ID only where a collision actually
  occurs, so the common case stays readable.
