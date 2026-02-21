{
  description = "NixOS configuration of our builders";

  nixConfig.extra-substituters = [
    "https://nix-community.cachix.org"
    "https://temp-cache.nix-community.org"
  ];
  nixConfig.extra-trusted-public-keys = [
    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    "temp-cache.nix-community.org-1:RSXIfGjilfBsilDvj03/VnL/9qAxacBnb1YQvSdCoDc="
  ];

  inputs = {
    # keep-sorted start
    buildbot-nix.inputs.flake-parts.follows = "flake-parts";
    buildbot-nix.inputs.hercules-ci-effects.follows = "hercules-ci-effects";
    buildbot-nix.inputs.nixpkgs.follows = "nixpkgs";
    buildbot-nix.inputs.treefmt-nix.follows = "treefmt-nix";
    buildbot-nix.url = "github:qowoz/buildbot-nix/infra";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    disko.url = "github:nix-community/disko";
    empty.url = "github:nix-systems/empty";
    flake-compat.url = "github:NixOS/flake-compat";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";
    flake-parts.url = "github:hercules-ci/flake-parts";
    freebsd-nix.inputs.flake-compat.follows = "flake-compat";
    freebsd-nix.inputs.flake-parts.follows = "flake-parts";
    freebsd-nix.inputs.git-hooks-nix.follows = "empty";
    freebsd-nix.inputs.nixpkgs-23-11.follows = "empty";
    freebsd-nix.inputs.nixpkgs-regression.follows = "empty";
    freebsd-nix.inputs.nixpkgs.follows = "nixbsd-nixpkgs";
    freebsd-nix.url = "github:qowoz/nix/freebsd-lowdown";
    hercules-ci-effects.inputs.flake-parts.follows = "flake-parts";
    hercules-ci-effects.inputs.nixpkgs.follows = "nixpkgs";
    hercules-ci-effects.url = "github:hercules-ci/hercules-ci-effects";
    lite-config.url = "github:yelite/lite-config";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-darwin.url = "github:nix-darwin/nix-darwin";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";
    nix-index-database.url = "github:nix-community/nix-index-database";
    nixbsd-nixpkgs.url = "git+https://github.com/NixOS/nixpkgs?shallow=1&rev=f84d6f6cd5f17d594439710f40349ba7d0706f4b";
    nixbsd.inputs.cppnix.follows = "freebsd-nix";
    nixbsd.inputs.flake-compat.follows = "flake-compat";
    nixbsd.inputs.nixpkgs.follows = "nixbsd-nixpkgs";
    nixbsd.url = "github:qowoz/nixbsd/infra";
    nixpkgs-update-github-releases.flake = false;
    nixpkgs-update-github-releases.url = "github:nix-community/nixpkgs-update-github-releases";
    nixpkgs-update.inputs.mmdoc.follows = "empty";
    nixpkgs-update.inputs.treefmt-nix.follows = "treefmt-nix";
    nixpkgs-update.url = "github:nix-community/nixpkgs-update/infra";
    nixpkgs.url = "git+https://github.com/NixOS/nixpkgs?shallow=1&ref=nixos-unstable-small";
    nur-update.inputs.nixpkgs.follows = "nixpkgs";
    nur-update.url = "github:nix-community/nur-update";
    quadlet-nix.inputs.flake-parts.follows = "flake-parts";
    quadlet-nix.inputs.nixpkgs.follows = "nixpkgs";
    quadlet-nix.url = "github:mirkolenz/quadlet-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
    sops-nix.url = "github:qowoz/sops-nix/ssh"; # rebased https://github.com/Mic92/sops-nix/pull/779
    srvos.inputs.nixpkgs.follows = "nixpkgs";
    srvos.url = "github:nix-community/srvos";
    systems.url = "github:nix-systems/default";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    # keep-sorted end
  };

  outputs =
    inputs@{ flake-parts, self, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = import inputs.systems;

      imports = [
        ./dev/dnscontrol.nix
        ./dev/docs.nix
        ./dev/effect-deploy.nix
        ./dev/sops.nix
        ./dev/terraform.nix
        ./modules
        inputs.hercules-ci-effects.flakeModule
        inputs.lite-config.flakeModule
        inputs.treefmt-nix.flakeModule
      ];

      lite-config =
        { lib, ... }:
        {
          nixpkgs = {
            overlays = [
              (final: prev: (import ./dev/packages.nix { inherit final prev inputs; }))
            ];
          };

          hostModuleDir = ./hosts;

          hosts = {
            build01.system = "x86_64-linux";
            build02.system = "x86_64-linux";
            build03.system = "x86_64-linux";
            build04.system = "aarch64-linux";
            build05.system = "aarch64-linux";
            darwin01.system = "aarch64-darwin";
            darwin02.system = "aarch64-darwin";
            web01.system = "x86_64-linux";
          };

          systemModules = [
            (
              { hostPlatform, ... }:
              {
                imports =
                  lib.optionals hostPlatform.isDarwin [ ./modules/darwin/common ]
                  ++ lib.optionals hostPlatform.isLinux [ ./modules/nixos/common ];
              }
            )
          ];
        };

      perSystem =
        {
          inputs',
          lib,
          pkgs,
          self',
          system,
          ...
        }:
        {
          imports = [
            ./dev/shell.nix
          ];
          treefmt = {
            flakeCheck = system == "x86_64-linux";
            imports = [ ./dev/treefmt.nix ];
          };

          checks = {
            inherit (self') formatter;
          }
          // lib.mapAttrs' (n: lib.nameValuePair "devShell-${n}") self'.devShells
          //
            lib.mapAttrs' (name: config: lib.nameValuePair "host-${name}" config.config.system.build.toplevel)
              (
                (lib.filterAttrs (_: config: config.pkgs.stdenv.hostPlatform.system == system)) (
                  self.darwinConfigurations // self.nixosConfigurations
                )
              )
          // lib.mapAttrs' (name: config: lib.nameValuePair "host-${name}" config.config.system.build.vm) (
            (lib.filterAttrs (_: config: config.pkgs.stdenv.buildPlatform.system == system))
              self.nixbsdConfigurations
          )
          // pkgs.lib.optionalAttrs (system == "aarch64-linux" || system == "x86_64-linux") {
            nixosTests-kernel-clang-lto = pkgs.callPackage ./dev/kernel-test.nix { inherit inputs; };
          }
          // pkgs.lib.optionalAttrs (system == "x86_64-linux") (
            {
              inherit (self'.packages)
                dnscontrol-check
                docs
                docs-linkcheck
                sops-check
                terraform-validate
                ;
              nixpkgs-update-supervisor-test = pkgs.callPackage ./hosts/build02/supervisor_test.nix { };
            }
            // lib.mapAttrs' (name: value: lib.nameValuePair "nixosTests-${name}" value) {
              inherit (pkgs.nixosTests)
                buildbot
                harmonia
                hydra
                ;
              buildbot-nix = inputs'.buildbot-nix.checks.poller;
              buildbot-nix-scheduled-effects = inputs'.buildbot-nix.checks.scheduled-effects;
              quadlet-nix = inputs'.quadlet-nix.checks.nixos;
            }
          );
        };

      flake.nixbsdConfigurations =
        let
          inherit (inputs.nixbsd.lib) nixbsdSystem;
          common = [ ./hosts/freebsd/configuration.nix ];
        in
        {
          build01-freebsd = nixbsdSystem {
            modules = common ++ [
              {
                virtualisation.vmVariant.virtualisation.cores = 12; # 1/2
                virtualisation.vmVariant.virtualisation.memorySize = 64 * 1024; # 1/2
              }
            ];
          };
          build03-freebsd = nixbsdSystem {
            modules = common ++ [
              {
                virtualisation.vmVariant.virtualisation.cores = 48; # 1/2
                virtualisation.vmVariant.virtualisation.memorySize = 128 * 1024; # 1/2
              }
            ];
          };
        };
    };
}
