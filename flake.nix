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
    hydra.url = "github:NixOS/hydra";
    hydra.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self
            , nixpkgs
            , nixpkgs-update
            , nixpkgs-update-github-releases
            , nixpkgs-update-pypi-releases
            , sops-nix
            , hydra
            }: {
    devShell.x86_64-linux = let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
    in pkgs.callPackage ./shell.nix {
      inherit (sops-nix.packages.x86_64-linux) sops-import-keys-hook;
    };
    nixosConfigurations = let
      common = [
        sops-nix.nixosModules.sops
      ];
    in {
      nix-community-build01 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = common ++ [
          ./build01/configuration.nix
        ];
      };

      nix-community-build02 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = common ++ [
          (import ./build02/nixpkgs-update.nix {
            inherit nixpkgs-update
              nixpkgs-update-github-releases
              nixpkgs-update-pypi-releases;
          })
          ./build02/configuration.nix
        ];
      };

      nix-community-build03 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = common ++ [
          (import ./services/hydra {
            inherit hydra;
          })

          ./build03/configuration.nix
        ];
      };

      nix-community-build04 = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = common ++ [
          ./build04/configuration.nix
        ];
      };
    };
  };
}
