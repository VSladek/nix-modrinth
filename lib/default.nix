{ lib, nmLib }:
rec {
  /**
    Turn an arbitrary Modrinth version string (e.g. "0.20.0+mc1.21.10") into a
    string that is safe to use as a Nix attribute name. Quoting is still
    required at the call site (e.g. `set."0_20_0-mc1_21_10"`) since the result
    commonly starts with a digit.

    Builds on nix-minecraft's `escapeVersion` (dots/spaces -> `_`), extended
    with the extra punctuation that shows up in mod build metadata but not in
    Mojang/Fabric version strings.
  */
  escapeVersion =
    v: nmLib.escapeVersion (lib.replaceStrings [ "+" "~" "(" ")" ] [ "-" "_" "_" "_" ] v);

  /**
    Given an attrset of `{ <version> = { datePublished, versionType, ... }; ... }`
    (the shape of a generated mods/<loader>/<name>.json lock file), return the
    version string whose `datePublished` is newest, preferring `versionType ==
    "release"` builds over alpha/beta ones when both exist.

    We deliberately sort by publish date rather than by the version string
    itself: `lib.versionOlder` assumes a disciplined dotted-version scheme,
    which holds for Mojang/Fabric but not for arbitrary Modrinth mod authors
    (build metadata, differing schemes, etc).

    The release-preference matters because a project's most recently
    published version can be an alpha/beta dev snapshot even when a
    still-current stable release exists further back in the list — sorting
    by date alone picked a GrimAC alpha with a broken/mismatched shaded
    PacketEvents+Adventure dependency (crashed on startup) over the last
    working stable release.
  */
  latestByDate =
    versions:
    let
      entries = lib.mapAttrsToList (name: value: { inherit name value; }) versions;
      releaseEntries = builtins.filter (e: e.value.versionType == "release") entries;
      candidates = if releaseEntries != [ ] then releaseEntries else entries;
      sorted = lib.sort (a: b: a.value.datePublished < b.value.datePublished) candidates;
    in
    (lib.last sorted).name;

  /**
    Filter a mod's lock entries down to those compatible with `gameVersion`.
  */
  versionsForGame =
    gameVersion: locks: lib.filterAttrs (_: v: builtins.elem gameVersion v.gameVersions) locks;
}
