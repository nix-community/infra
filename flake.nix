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
    blueprint.inputs.nixpkgs.follows = "nixpkgs";
    blueprint.inputs.systems.follows = "systems";
    blueprint.url = "github:numtide/blueprint";
    buildbot-nix.inputs.flake-parts.follows = "flake-parts";
    buildbot-nix.inputs.nixpkgs.follows = "nixpkgs";
    buildbot-nix.inputs.treefmt-nix.follows = "treefmt-nix";
    buildbot-nix.url = "github:nix-community/buildbot-nix";
    cgroup-exporter.inputs.nixpkgs.follows = "nixpkgs";
    cgroup-exporter.url = "github:arianvp/cgroup-exporter";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    disko.url = "github:nix-community/disko";
    empty.url = "github:nix-systems/empty";
    flake-compat.url = "github:nix-community/flake-compat";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";
    flake-parts.url = "github:hercules-ci/flake-parts";
    hercules-ci-effects.inputs.flake-parts.follows = "flake-parts";
    hercules-ci-effects.inputs.nixpkgs.follows = "nixpkgs";
    hercules-ci-effects.url = "github:hercules-ci/hercules-ci-effects";
    hydra.flake = false;
    hydra.url = "github:qowoz/hydra/community";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";
    nix-index-database.url = "github:nix-community/nix-index-database";
    nixos-facter-modules.url = "github:numtide/nixos-facter-modules";
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

  # overlays = [
  #   (final: prev: {
  #     hydra = (prev.hydra.override { nix = final.nixVersions.nix_2_24; }).overrideAttrs (o: {
  #       version = inputs.hydra.shortRev;
  #       src = inputs.hydra;
  #       buildInputs = o.buildInputs ++ [ final.perlPackages.DBIxClassHelpers ];
  #     });
  #   })
  # ];

  # checks =
  #   let
  #     darwinConfigurations = lib.mapAttrs' (
  #       name: config: lib.nameValuePair "host-${name}" config.config.system.build.toplevel
  #     ) ((lib.filterAttrs (_: config: config.pkgs.system == system)) self.darwinConfigurations);
  #     devShells = lib.mapAttrs' (n: lib.nameValuePair "devShell-${n}") self'.devShells;
  #     nixosConfigurations = lib.mapAttrs' (
  #       name: config: lib.nameValuePair "host-${name}" config.config.system.build.toplevel
  #     ) ((lib.filterAttrs (_: config: config.pkgs.system == system)) self.nixosConfigurations);
  #   in
  #   darwinConfigurations
  #   // devShells
  #   // {
  #     inherit (self') formatter;
  #   }
  #   // nixosConfigurations
  #   // pkgs.lib.optionalAttrs (system == "x86_64-linux") {
  #     inherit (self'.packages) docs docs-linkcheck;
  #     nixpkgs-update-supervisor-test = pkgs.callPackage ./hosts/build02/supervisor_test.nix { };
  #     nixosTests-buildbot = pkgs.nixosTests.buildbot;
  #     nixosTests-buildbot-nix-master = inputs'.buildbot-nix.checks.master;
  #     nixosTests-buildbot-nix-worker = inputs'.buildbot-nix.checks.worker;
  #     nixosTests-hydra = pkgs.nixosTests.hydra.hydra;
  #   };

  outputs =
    inputs:
    inputs.blueprint {
      inherit inputs;
      nixpkgs.config.allowUnfreePredicate =
        pkg: builtins.elem (inputs.nixpkgs.lib.getName pkg) [ "terraform" ];
    };
}
