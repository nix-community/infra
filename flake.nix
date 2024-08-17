{
  description = "NixOS configuration of our builders";

  nixConfig.extra-substituters = [ "https://nix-community.cachix.org" ];
  nixConfig.extra-trusted-public-keys = [
    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
  ];

  inputs = {
    agenix.inputs.darwin.follows = "nix-darwin";
    agenix.inputs.home-manager.follows = "empty";
    agenix.inputs.nixpkgs.follows = "nixpkgs";
    agenix.inputs.systems.follows = "systems";
    agenix.url = "github:ryantm/agenix";
    buildbot-nix.inputs.flake-parts.follows = "flake-parts";
    buildbot-nix.inputs.nixpkgs.follows = "nixpkgs";
    buildbot-nix.inputs.treefmt-nix.follows = "treefmt-nix";
    buildbot-nix.url = "github:qowoz/buildbot-nix/skipped-build-workers";
    comin.inputs.nixpkgs.follows = "nixpkgs";
    comin.url = "github:nlewo/comin/d3658c452024824235de2355ac3e156b10c3eaaf";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    disko.url = "github:nix-community/disko";
    empty.url = "github:nix-systems/empty";
    flake-compat.url = "github:nix-community/flake-compat";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-utils.inputs.systems.follows = "systems";
    flake-utils.url = "github:numtide/flake-utils";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-topology.inputs.devshell.follows = "empty";
    nix-topology.inputs.flake-utils.follows = "flake-utils";
    nix-topology.inputs.nixpkgs.follows = "nixpkgs";
    nix-topology.inputs.pre-commit-hooks.follows = "empty";
    nix-topology.url = "github:oddlama/nix-topology";
    nixpkgs-update-github-releases.flake = false;
    nixpkgs-update-github-releases.url = "github:nix-community/nixpkgs-update-github-releases";
    nixpkgs-update.inputs.mmdoc.follows = "empty";
    nixpkgs-update.inputs.runtimeDeps.follows = "nixpkgs";
    nixpkgs-update.inputs.treefmt-nix.follows = "treefmt-nix";
    nixpkgs-update.url = "github:nix-community/nixpkgs-update";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";
    nur-update.inputs.nixpkgs.follows = "nixpkgs";
    nur-update.url = "github:nix-community/nur-update";
    sops-nix.inputs.nixpkgs-stable.follows = "empty";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
    sops-nix.url = "github:Mic92/sops-nix";
    srvos.inputs.nixpkgs.follows = "nixpkgs";
    srvos.url = "github:nix-community/srvos";
    systems.url = "github:nix-systems/default";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };

  outputs =
    inputs@{ flake-parts, self, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = import inputs.systems;

      imports = [
        inputs.nix-topology.flakeModule
        inputs.treefmt-nix.flakeModule
      ];

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
            ./dev/docs.nix
            ./dev/shell.nix
            ./terraform/shell.nix
          ];
          treefmt = {
            flakeCheck = system == "x86_64-linux";
            imports = [ ./dev/treefmt.nix ];
          };

          _module.args.pkgs = import inputs.nixpkgs {
            inherit system;
            config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [ "terraform" ];
            overlays = [ inputs.nix-topology.overlays.default ];
          };

          packages.topology = self.topology.${system}.config.output;

          checks =
            let
              darwinConfigurations = lib.mapAttrs' (
                name: config: lib.nameValuePair name config.config.system.build.toplevel
              ) ((lib.filterAttrs (_: config: config.pkgs.system == system)) self.darwinConfigurations);
              devShells = lib.mapAttrs' (n: lib.nameValuePair "devShell-${n}") self'.devShells;
              nixosConfigurations = lib.mapAttrs' (
                name: config: lib.nameValuePair "nixos-${name}" config.config.system.build.toplevel
              ) ((lib.filterAttrs (_: config: config.pkgs.system == system)) self.nixosConfigurations);
            in
            darwinConfigurations
            // devShells
            // {
              inherit (self') formatter;
            }
            // nixosConfigurations
            // pkgs.lib.optionalAttrs (system == "x86_64-linux") {
              inherit (self'.packages) docs docs-linkcheck;
              nixpkgs-update-supervisor-test = pkgs.callPackage ./hosts/build02/supervisor_test.nix { };
              nixosTests-buildbot = pkgs.nixosTests.buildbot;
              nixosTests-buildbot-nix-master = inputs'.buildbot-nix.checks.master;
              nixosTests-buildbot-nix-worker = inputs'.buildbot-nix.checks.worker;
              nixosTests-hydra = pkgs.nixosTests.hydra.hydra_unstable;
            };
        };

      flake.darwinConfigurations =
        let
          darwinSystem =
            args:
            inputs.nix-darwin.lib.darwinSystem (
              {
                specialArgs = {
                  inherit inputs;
                };
              }
              // args
            );
        in
        {
          darwin01 = darwinSystem {
            pkgs = inputs.nixpkgs.legacyPackages.aarch64-darwin;
            modules = [ ./hosts/darwin01/configuration.nix ];
          };
          darwin02 = darwinSystem {
            pkgs = inputs.nixpkgs.legacyPackages.aarch64-darwin;
            modules = [ ./hosts/darwin02/configuration.nix ];
          };
        };

      flake.nixosConfigurations =
        let
          nixosSystem =
            args:
            inputs.nixpkgs.lib.nixosSystem (
              {
                specialArgs = {
                  inherit inputs;
                };
              }
              // args
            );
        in
        {
          build01 = nixosSystem {
            pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
            modules = [ ./hosts/build01/configuration.nix ];
          };
          build02 = nixosSystem {
            pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
            modules = [ ./hosts/build02/configuration.nix ];
          };
          build03 = nixosSystem {
            pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
            modules = [ ./hosts/build03/configuration.nix ];
          };
          build04 = nixosSystem {
            pkgs = inputs.nixpkgs.legacyPackages.aarch64-linux;
            modules = [ ./hosts/build04/configuration.nix ];
          };
          web02 = nixosSystem {
            pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
            modules = [ ./hosts/web02/configuration.nix ];
          };
        };

      flake.darwinModules = {
        common = ./modules/darwin/common;

        builder = ./modules/darwin/builder.nix;
        community-builder = ./modules/darwin/community-builder;
        hercules-ci = ./modules/darwin/hercules-ci.nix;
        remote-builder = ./modules/darwin/remote-builder.nix;
      };

      flake.nixosModules = {
        common = ./modules/nixos/common;

        buildbot = ./modules/nixos/buildbot.nix;
        builder = ./modules/nixos/builder.nix;
        community-builder = ./modules/nixos/community-builder;
        disko-zfs = ./modules/nixos/disko-zfs.nix;
        github-org-backup = ./modules/nixos/github-org-backup.nix;
        hercules-ci = ./modules/nixos/hercules-ci.nix;
        hydra = ./modules/nixos/hydra.nix;
        monitoring = ./modules/nixos/monitoring;
        nur-update = ./modules/nixos/nur-update.nix;
        remote-builder = ./modules/nixos/remote-builder.nix;
        watch-store = ./modules/nixos/watch-store.nix;
      };
    };
}
