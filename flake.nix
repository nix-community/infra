{
  description = "NixOS configuration of our builders";

  inputs = {
    #nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";
    # https://github.com/NixOS/nixpkgs/pull/168186
    nixpkgs.url = "github:Mic92/nixpkgs/gidgethub";
    #nixpkgs-update.url = "github:ryantm/nixpkgs-update";
    nixpkgs-update.url = "github:Mic92/nixpkgs-update/build-fixes";
    nixpkgs-update-github-releases.url = "github:ryantm/nixpkgs-update-github-releases";
    nixpkgs-update-github-releases.flake = false;
    nixpkgs-update-pypi-releases.url = "github:ryantm/nixpkgs-update-pypi-releases";
    nixpkgs-update-pypi-releases.flake = false;
    sops-nix.url = "github:Mic92/sops-nix";
    hercules-ci-effects.url = "github:hercules-ci/hercules-ci-effects";
    marvin-mk2.url = "github:timokau/marvin-mk2";
    marvin-mk2.flake = false;
    hydra.url = "github:NixOS/hydra";
  };

  outputs = { self
            , nixpkgs
            , nixpkgs-update
            , nixpkgs-update-github-releases
            , nixpkgs-update-pypi-releases
            , sops-nix
            , hercules-ci-effects
            , marvin-mk2
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
      build01 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = common ++ [
          ./build01/configuration.nix
        ];
      };

      build02 = nixpkgs.lib.nixosSystem {
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

      build03 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = common ++ [
          (import ./services/marvin-mk2.nix {
            inherit marvin-mk2;
          })
          (import ./services/hydra {
            inherit hydra;
          })

          ./build03/configuration.nix
        ];
      };

      build04 = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = common ++ [
          ./build04/configuration.nix
        ];
      };
    };
  };
}
