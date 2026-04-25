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
    adios-flake.url = "github:Mic92/adios-flake/flake-parts-compat";
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
    freebsd-nix.url = "github:NixOS/nix/a37db9d249afd61a81ae26368696f60e065d6f61";
    hercules-ci-effects.inputs.flake-parts.follows = "flake-parts";
    hercules-ci-effects.inputs.nixpkgs.follows = "nixpkgs";
    hercules-ci-effects.url = "github:hercules-ci/hercules-ci-effects";
    lite-config.url = "github:yelite/lite-config";
    mimalloc-nix.inputs.flake-compat.follows = "flake-compat";
    mimalloc-nix.inputs.flake-parts.follows = "flake-parts";
    mimalloc-nix.inputs.git-hooks-nix.follows = "empty";
    mimalloc-nix.inputs.nixpkgs-23-11.follows = "empty";
    mimalloc-nix.inputs.nixpkgs-regression.follows = "empty";
    mimalloc-nix.inputs.nixpkgs.follows = "nixpkgs";
    mimalloc-nix.url = "github:qowoz/nix/mimalloc";
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
    inputs@{ adios-flake, self, ... }:
    adios-flake.lib.mkFlake { inherit inputs; } {
      systems = import inputs.systems;

      imports = [
        ./dev/dnscontrol.nix
        ./dev/docs.nix
        ./dev/sops.nix
        ./dev/terraform.nix
        ./modules
      ];

      flake.herculesCI = inputs.hercules-ci-effects.lib.mkHerculesCI { inherit inputs; } {
        imports = [ ./dev/effect-deploy.nix ];
      };

      perSystem =
        {
          lib,
          pkgs,
          self',
          system,
          ...
        }:
        let
          pkgs' = import inputs.nixpkgs {
            inherit system;
            config.allowDeprecatedx86_64Darwin = true;
            overlays = [ self.overlays.default ];
          };
          treefmtEval = inputs.treefmt-nix.lib.evalModule pkgs' ./dev/treefmt.nix;
        in
        {
          #_module.args.pkgs = import inputs.nixpkgs {
          #  inherit system;
          #  config.allowDeprecatedx86_64Darwin = true;
          #  overlays = [ self.overlays.default ];
          #};

          devShells.default =
            with pkgs';
            mkShellNoCC {
              packages = [
                deploykitEnv
                jq
                sops
                ssh-to-age
                yq-go
              ];
            };

          formatter = treefmtEval.config.build.wrapper;

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
              treefmt = treefmtEval.config.build.check self;
            }
            // lib.mapAttrs' (name: value: lib.nameValuePair "nixosTests-${name}" value) {
              inherit (pkgs.nixosTests)
                buildbot
                harmonia
                hydra
                ;
              buildbot-nix = inputs.buildbot-nix.checks.${system}.poller;
              buildbot-nix-scheduled-effects = inputs.buildbot-nix.checks.${system}.scheduled-effects;
              quadlet-nix = inputs.quadlet-nix.checks.${system}.nixos;
            }
          );
        };

      flake.overlays.default = final: prev: (import ./dev/packages.nix { inherit final prev inputs; });

      flake.darwinConfigurations =
        let
          darwinSystem =
            hostName:
            inputs.nix-darwin.lib.darwinSystem {
              specialArgs = { inherit inputs; };
              modules = [
                ./hosts/${hostName}
                ./modules/darwin/common
                {
                  nixpkgs.overlays = [ self.overlays.default ];
                  networking = { inherit hostName; };
                }
              ];
            };

          hosts = [
            "darwin01"
            "darwin02"
          ];
        in
        inputs.nixpkgs.lib.genAttrs hosts darwinSystem;

      flake.nixosConfigurations =
        let
          nixosSystem =
            hostName:
            inputs.nixpkgs.lib.nixosSystem {
              specialArgs = { inherit inputs; };
              modules = [
                ./hosts/${hostName}
                ./modules/nixos/common
                {
                  nixpkgs.overlays = [ self.overlays.default ];
                  networking = { inherit hostName; };
                }
              ];
            };

          hosts = [
            "build01"
            "build02"
            "build03"
            "build04"
            "build05"
            "web01"
          ];
        in
        inputs.nixpkgs.lib.genAttrs hosts nixosSystem;

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
