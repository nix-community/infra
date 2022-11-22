{
  description = "NixOS configuration of our builders";

  nixConfig.extra-substituters = [
    "https://nix-community.cachix.org"
    "https://nixpkgs-update.cachix.org"
  ];
  nixConfig.extra-trusted-public-keys = [
    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    "nixpkgs-update.cachix.org-1:6y6Z2JdoL3APdu6/+Iy8eZX2ajf09e4EE9SnxSML1W8="
  ];

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";
    nixpkgs-update.url = "github:ryantm/nixpkgs-update";
    nixpkgs-update-github-releases.url = "github:ryantm/nixpkgs-update-github-releases";
    nixpkgs-update-github-releases.flake = false;
    nixpkgs-update-pypi-releases.url = "github:ryantm/nixpkgs-update-pypi-releases";
    nixpkgs-update-pypi-releases.flake = false;
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";
  };

  outputs = {
    self,
    flake-parts,
    ...
  }:
    flake-parts.lib.mkFlake
      {inherit self;}
      {
        systems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];

        perSystem = {
          inputs',
          pkgs,
          ...
        }: {
          devShells.default = pkgs.callPackage ./shell.nix {
            inherit (inputs'.sops-nix.packages) sops-import-keys-hook;
          };
        };
        flake.nixosConfigurations = let
          inherit (self.inputs.nixpkgs.lib) nixosSystem;
          common = [
            self.inputs.sops-nix.nixosModules.sops
            { _module.args.inputs = self.inputs; }
          ];
        in {
          "build01.nix-community.org" = nixosSystem {
            system = "x86_64-linux";
            modules =
              common
              ++ [
                ./build01/configuration.nix
              ];
          };

          "build02.nix-community.org" = nixosSystem {
            system = "x86_64-linux";
            modules =
              common
              ++ [
                (import ./build02/nixpkgs-update.nix {
                  inherit
                    (self.inputs)
                    nixpkgs-update
                    nixpkgs-update-github-releases
                    nixpkgs-update-pypi-releases
                    ;
                })
                ./build02/configuration.nix
              ];
          };

          "build03.nix-community.org" = nixosSystem {
            system = "x86_64-linux";
            modules =
              common
              ++ [
                ./build03/configuration.nix
              ];
          };

          "build04.nix-community.org" = nixosSystem {
            system = "aarch64-linux";
            modules =
              common
              ++ [
                ./build04/configuration.nix
              ];
          };
        };
      };
}
