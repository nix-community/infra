{
  description = "NixOS configuration of our builders";

  nixConfig.extra-substituters = [ "https://nix-community.cachix.org" ];
  nixConfig.extra-trusted-public-keys = [
    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
  ];

  inputs = {
    # keep-sorted start
    buildbot-nix.inputs.flake-parts.follows = "flake-parts";
    buildbot-nix.inputs.hercules-ci-effects.follows = "hercules-ci-effects";
    buildbot-nix.inputs.nixpkgs.follows = "nixpkgs";
    buildbot-nix.inputs.treefmt-nix.follows = "treefmt-nix";
    buildbot-nix.url = "github:nix-community/buildbot-nix";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    disko.url = "github:nix-community/disko";
    empty.url = "github:nix-systems/empty";
    flake-compat.url = "github:nix-community/flake-compat";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";
    flake-parts.url = "github:hercules-ci/flake-parts";
    hercules-ci-effects.inputs.flake-parts.follows = "flake-parts";
    hercules-ci-effects.inputs.nixpkgs.follows = "nixpkgs";
    hercules-ci-effects.url = "github:qowoz/hercules-ci-effects/darwin-sudo";
    lite-config.url = "github:yelite/lite-config";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-darwin.url = "github:nix-darwin/nix-darwin";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";
    nix-index-database.url = "github:nix-community/nix-index-database";
    nixos-facter-modules.url = "github:nix-community/nixos-facter-modules";
    nixpkgs-update-github-releases.flake = false;
    nixpkgs-update-github-releases.url = "github:nix-community/nixpkgs-update-github-releases";
    nixpkgs-update.inputs.mmdoc.follows = "empty";
    nixpkgs-update.inputs.treefmt-nix.follows = "treefmt-nix";
    nixpkgs-update.url = "github:nix-community/nixpkgs-update/infra";
    nixpkgs.url = "git+https://github.com/NixOS/nixpkgs?shallow=1&ref=nixos-unstable-small";
    nur-update.inputs.nixpkgs.follows = "nixpkgs";
    nur-update.url = "github:nix-community/nur-update";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
    sops-nix.url = "github:Mic92/sops-nix";
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
            config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [ "terraform" ];
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
            web02.system = "x86_64-linux";
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

          checks =
            {
              inherit (self') formatter;
            }
            // lib.mapAttrs' (n: lib.nameValuePair "devShell-${n}") self'.devShells
            //
              lib.mapAttrs' (name: config: lib.nameValuePair "host-${name}" config.config.system.build.toplevel)
                (
                  (lib.filterAttrs (_: config: config.pkgs.hostPlatform.system == system)) (
                    self.darwinConfigurations // self.nixosConfigurations
                  )
                )
            // pkgs.lib.optionalAttrs (system == "x86_64-linux") {
              inherit (self'.packages)
                dnscontrol-check
                docs
                docs-linkcheck
                sops-check
                terraform-validate
                ;
              nixpkgs-update-supervisor-test = pkgs.callPackage ./hosts/build02/supervisor_test.nix { };
              nixosTests-buildbot = pkgs.nixosTests.buildbot;
              nixosTests-buildbot-nix-master = inputs'.buildbot-nix.checks.master;
              nixosTests-buildbot-nix-worker = inputs'.buildbot-nix.checks.worker;
              nixosTests-harmonia = pkgs.nixosTests.harmonia;
              nixosTests-hydra = pkgs.nixosTests.hydra;
            };
        };
    };
}
