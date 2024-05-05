{
  description = "NixOS configuration of our builders";

  nixConfig.extra-substituters = [
    "https://nix-community.cachix.org"
  ];
  nixConfig.extra-trusted-public-keys = [
    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
  ];

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
    sops-nix.inputs.nixpkgs-stable.follows = "";
    srvos.url = "github:nix-community/srvos";
    # actually not used when using the modules but than nothing ever will try to fetch this nixpkgs variant
    srvos.inputs.nixpkgs.follows = "nixpkgs";

    # rebased patch from https://github.com/ryantm/agenix/pull/241
    agenix.url = "github:qowoz/agenix/darwin";
    agenix.inputs.nixpkgs.follows = "nixpkgs";
    agenix.inputs.home-manager.follows = "";
    agenix.inputs.darwin.follows = "nix-darwin";

    nixpkgs-update.url = "github:nix-community/nixpkgs-update";
    nixpkgs-update.inputs.mmdoc.follows = "";
    nixpkgs-update.inputs.treefmt-nix.follows = "treefmt-nix";
    nixpkgs-update-github-releases.url = "github:nix-community/nixpkgs-update-github-releases";
    nixpkgs-update-github-releases.flake = false;

    buildbot-nix.url = "github:Mic92/buildbot-nix";
    buildbot-nix.inputs.nixpkgs.follows = "nixpkgs";
    buildbot-nix.inputs.flake-parts.follows = "flake-parts";
    buildbot-nix.inputs.treefmt-nix.follows = "treefmt-nix";

    nur-update.url = "github:nix-community/nur-update";
    nur-update.inputs.nixpkgs.follows = "nixpkgs";

    comin.url = "github:nlewo/comin";
    comin.inputs.nixpkgs.follows = "nixpkgs";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs @ { flake-parts, self, ... }:
    flake-parts.lib.mkFlake
      { inherit inputs; }
      {
        systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];

        imports = [
          inputs.treefmt-nix.flakeModule
        ];

        perSystem = { config, inputs', lib, pkgs, self', system, ... }:
          let
            defaultPlatform = pkgs.stdenv.hostPlatform.system == "x86_64-linux";
          in
          {
            imports = [
              ./dev/shell.nix
              ./terraform/shell.nix
            ];
            treefmt = {
              flakeCheck = defaultPlatform;
              imports = [ ./dev/treefmt.nix ];
            };

            checks =
              let
                darwinConfigurations = lib.mapAttrs' (name: config: lib.nameValuePair name config.config.system.build.toplevel) ((lib.filterAttrs (_: config: config.pkgs.system == system)) self.darwinConfigurations);
                devShells = lib.mapAttrs' (n: lib.nameValuePair "devShell-${n}") self'.devShells;
                nixosConfigurations = lib.mapAttrs' (name: config: lib.nameValuePair "nixos-${name}" config.config.system.build.toplevel) ((lib.filterAttrs (_: config: config.pkgs.system == system)) self.nixosConfigurations);
                packages = lib.mapAttrs' (n: lib.nameValuePair "package-${n}") self'.packages;
              in
              darwinConfigurations // devShells // { inherit (self') formatter; } // nixosConfigurations // packages
              // pkgs.lib.optionalAttrs defaultPlatform {
                nixosTests-buildbot = pkgs.nixosTests.buildbot;
                nixosTests-buildbot-nix-master = inputs'.buildbot-nix.checks.master;
                nixosTests-buildbot-nix-worker = inputs'.buildbot-nix.checks.worker;
                nixosTests-hydra = pkgs.nixosTests.hydra.hydra_unstable;
              };

            packages = pkgs.lib.optionalAttrs defaultPlatform {
              nixpkgs-update-supervisor-test = pkgs.callPackage ./hosts/build02/supervisor_test.nix { };
              pages = pkgs.runCommand "pages"
                {
                  buildInputs = [ config.devShells.mkdocs.nativeBuildInputs ];
                } ''
                cd ${self}
                mkdocs build --strict --site-dir $out
              '';
            };
          };

        flake.darwinConfigurations =
          let
            inherit (self.lib) darwinSystem;
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
            darwin03 = darwinSystem {
              pkgs = inputs.nixpkgs.legacyPackages.aarch64-darwin;
              modules = [ ./hosts/darwin03/configuration.nix ];
            };
          };

        flake.nixosConfigurations =
          let
            inherit (self.lib) nixosSystem;
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
          hercules-ci = ./modules/darwin/hercules-ci;
          remote-builder = ./modules/darwin/remote-builder.nix;
        };

        flake.nixosModules = {
          common = ./modules/nixos/common;

          buildbot = ./modules/nixos/buildbot.nix;
          builder = ./modules/nixos/builder.nix;
          community-builder = ./modules/nixos/community-builder;
          disko-raid = ./modules/nixos/disko-raid.nix;
          disko-zfs = ./modules/nixos/disko-zfs.nix;
          github-org-backup = ./modules/nixos/github-org-backup.nix;
          hercules-ci = ./modules/nixos/hercules-ci;
          hydra = ./modules/nixos/hydra.nix;
          monitoring = ./modules/nixos/monitoring;
          nur-update = ./modules/nixos/nur-update.nix;
          remote-builder = ./modules/nixos/remote-builder.nix;
          watch-store = ./modules/nixos/watch-store.nix;
        };

        flake.lib.darwinSystem = args:
          inputs.nix-darwin.lib.darwinSystem ({ specialArgs = { inherit inputs; }; } // args);
        flake.lib.nixosSystem = args:
          inputs.nixpkgs.lib.nixosSystem ({ specialArgs = { inherit inputs; }; } // args);
      };
}
