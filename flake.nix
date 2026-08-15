{
  description = "A generated, versioned database of Modrinth mods for Nix, in the style of nix-minecraft's server package sets";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-minecraft.url = "github:Infinidoge/nix-minecraft";
  };

  outputs =
    { self, nixpkgs, nix-minecraft, ... }:
    let
      forAllSystems = nixpkgs.lib.genAttrs [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
    in
    {
      overlay = import ./overlay.nix { nmLib = nix-minecraft.lib; };
      overlays.default = self.overlay;

      lib = import ./lib {
        lib = nixpkgs.lib;
        nmLib = nix-minecraft.lib;
      };

      legacyPackages = forAllSystems (
        system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        import ./default.nix {
          inherit pkgs;
          nmLib = nix-minecraft.lib;
        }
      );
    };
}
