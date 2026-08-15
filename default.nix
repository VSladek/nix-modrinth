{
  pkgs,
  lib ? pkgs.lib,
  nmLib,
}:

/**
  Builds the `modrinthMods` package set from the generated `mods/<loader>/*.json`
  lock files. For each loader (e.g. "fabric", "velocity") this exposes, per
  tracked mod:

    modrinthMods.<loader>.byVersion.<name>.<escapedVersion>   # every locked version, addressed directly
    modrinthMods.<loader>.latest.<name>                       # newest locked version overall
    modrinthMods.<loader>."<escapedGameVersion>".<name>       # newest version compatible with that game version
                                                                # (mirrors nix-minecraft's `fabricServers.fabric-1_21_10` style)

  Consumers pick whichever addressing style fits: `byGameVersion`-style
  lookups for "give me whatever lithium build works with 1.21.10", or
  `byVersion` to pin an exact release.
*/
let
  ourLib = import ./lib { inherit lib nmLib; };
  mkMod = pkgs.callPackage ./lib/mk-modrinth-mod.nix { };

  modsDir = ./mods;
  loaders = builtins.attrNames (builtins.readDir modsDir);

  mkModVersions =
    loaderDir: name:
    let
      locks = lib.importJSON (loaderDir + "/${name}.json");

      byVersion = lib.mapAttrs' (
        version: entry:
        lib.nameValuePair (ourLib.escapeVersion version) (mkMod {
          pname = name;
          inherit version;
          inherit (entry) url sha512;
        })
      ) locks;

      gameVersions = lib.unique (lib.concatMap (e: e.gameVersions) (lib.attrValues locks));

      # Keyed by the *escaped* game version, so entries from different mods
      # line up under the same key when merged across a loader's mods below.
      byGameVersion = lib.filterAttrs (_: v: v != null) (
        lib.genAttrs (map ourLib.escapeVersion gameVersions) (
          escapedGv:
          let
            matchingByGv = lib.filterAttrs (
              _: e: lib.any (gv: ourLib.escapeVersion gv == escapedGv) e.gameVersions
            ) locks;
          in
          if matchingByGv == { } then
            null
          else
            byVersion.${ourLib.escapeVersion (ourLib.latestByDate matchingByGv)}
        )
      );
    in
    {
      inherit byVersion byGameVersion;
      latest = byVersion.${ourLib.escapeVersion (ourLib.latestByDate locks)};
    };

  mkLoaderSet =
    loader:
    let
      loaderDir = modsDir + "/${loader}";
      lockFiles = lib.filterAttrs (n: t: t == "regular" && lib.hasSuffix ".json" n) (
        builtins.readDir loaderDir
      );
      modNames = map (f: lib.removeSuffix ".json" f) (builtins.attrNames lockFiles);

      byName = lib.genAttrs modNames (mkModVersions loaderDir);

      allEscapedGameVersions = lib.unique (
        lib.concatMap (m: lib.attrNames m.byGameVersion) (lib.attrValues byName)
      );

      byGameVersion = lib.genAttrs allEscapedGameVersions (
        escapedGv:
        lib.filterAttrs (_: v: v != null) (lib.mapAttrs (_: m: m.byGameVersion.${escapedGv} or null) byName)
      );
    in
    {
      byVersion = lib.mapAttrs (_: m: m.byVersion) byName;
      latest = lib.mapAttrs (_: m: m.latest) byName;
    }
    // byGameVersion;
in
lib.genAttrs loaders mkLoaderSet
