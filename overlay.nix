{ nmLib }:
final: prev: {
  modrinthMods = import ./default.nix {
    pkgs = final;
    inherit nmLib;
  };
}
