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
    Given an attrset of `{ <version> = { datePublished, ... }; ... }` (the
    shape of a generated mods/<loader>/<name>.json lock file), return the
    version string whose `datePublished` is newest.

    We deliberately sort by publish date rather than by the version string
    itself: `lib.versionOlder` assumes a disciplined dotted-version scheme,
    which holds for Mojang/Fabric but not for arbitrary Modrinth mod authors
    (build metadata, differing schemes, etc).
  */
  latestByDate =
    versions:
    let
      entries = lib.mapAttrsToList (name: value: { inherit name value; }) versions;
      sorted = lib.sort (a: b: a.value.datePublished < b.value.datePublished) entries;
    in
    (lib.last sorted).name;

  /**
    Filter a mod's lock entries down to those compatible with `gameVersion`.
  */
  versionsForGame =
    gameVersion: locks: lib.filterAttrs (_: v: builtins.elem gameVersion v.gameVersions) locks;
}
