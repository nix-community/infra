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
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
    sops-nix.inputs.nixpkgs-stable.follows = "";
    srvos.url = "github:numtide/srvos";
    # actually not used when using the modules but than nothing ever will try to fetch this nixpkgs variant
    srvos.inputs.nixpkgs.follows = "nixpkgs";

    nixpkgs-update.url = "github:ryantm/nixpkgs-update";
    nixpkgs-update.inputs.mmdoc.follows = "";
    nixpkgs-update-github-releases.url = "github:ryantm/nixpkgs-update-github-releases";
    nixpkgs-update-github-releases.flake = false;

    nur-update.url = "github:nix-community/nur-update";
    nur-update.inputs.nixpkgs.follows = "nixpkgs";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    hercules-ci-effects.url = "github:hercules-ci/hercules-ci-effects";
    hercules-ci-effects.inputs.flake-parts.follows = "flake-parts";
    hercules-ci-effects.inputs.hercules-ci-agent.follows = "";
    hercules-ci-effects.inputs.nixpkgs.follows = "nixpkgs";

    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    darwin.url = "github:LnL7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs @ { flake-parts, self, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];

      herculesCI = { lib, ... }: {
        ciSystems = [ "x86_64-linux" "aarch64-linux" ];

        onPush.default.outputs = {
          checks = lib.mkForce self.outputs.checks.x86_64-linux;
        };
      };

      hercules-ci.flake-update = {
        enable = true;
        createPullRequest = true;
        autoMergeMethod = "rebase";
        when = {
          hour = [ 2 ];
          dayOfWeek = [ "Mon" "Thu" ];
        };
      };

      hercules-ci.github-pages.branch = "master";

      imports = [
        inputs.hercules-ci-effects.flakeModule
        inputs.treefmt-nix.flakeModule
        ./effect.nix
        ./shell.nix
        ./modules
        # Hosts
        ./build01
        ./build02
        ./build03
        ./build04
        ./mac01
      ];

      perSystem = { config, pkgs, ... }: {
        treefmt.imports = [ ./treefmt.nix ];

        packages.pages = pkgs.runCommand "pages"
          {
            buildInputs = [ pkgs.python3.pkgs.mkdocs-material ];
          } ''
          cp -r ${pkgs.lib.cleanSource ./.}/* .
          mkdocs build --strict --site-dir $out
        '';

        hercules-ci.github-pages.settings.contents = config.packages.pages;
      };

      flake.lib.nixosSystem = args:
        inputs.nixpkgs.lib.nixosSystem ({ specialArgs = { inherit inputs; }; } // args);
    };
}
