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
    nixpkgs-update-pypi-releases.url = "github:ryantm/nixpkgs-update-pypi-releases";
    nixpkgs-update-pypi-releases.flake = false;

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
  };

  outputs = inputs @ { flake-parts, ... }:
    flake-parts.lib.mkFlake
      { inherit inputs; }
      {
        systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];

        imports = [
          ./treefmt.nix
        ];

        perSystem =
          { config
          , inputs'
          , pkgs
          , self'
          , ...
          }: {
            devShells.default = pkgs.callPackage ./shell.nix {
              inherit config;
            };
          };
        flake.nixosConfigurations =
          let
            inherit (inputs.nixpkgs.lib) nixosSystem;
            common = [
              { _module.args.inputs = inputs; }
              { srvos.flake = inputs.self; }
              inputs.sops-nix.nixosModules.sops
              inputs.srvos.nixosModules.server

              inputs.srvos.nixosModules.mixins-telegraf
              { networking.firewall.allowedTCPPorts = [ 9273 ]; }
            ];
          in
          {
            "build01.nix-community.org" = nixosSystem {
              system = "x86_64-linux";
              modules =
                common
                ++ [
                  ./build01/configuration.nix
                  inputs.srvos.nixosModules.hardware-hetzner-online-amd
                ];
            };

            "build02.nix-community.org" = nixosSystem {
              system = "x86_64-linux";
              modules =
                common
                ++ [
                  (import ./build02/nixpkgs-update.nix {
                    inherit
                      (inputs)
                      nixpkgs-update
                      nixpkgs-update-github-releases
                      nixpkgs-update-pypi-releases
                      ;
                  })
                  ./build02/configuration.nix
                  inputs.srvos.nixosModules.mixins-nginx
                  inputs.srvos.nixosModules.hardware-hetzner-online-amd
                ];
            };

            "build03.nix-community.org" = nixosSystem {
              system = "x86_64-linux";
              modules =
                common
                ++ [
                  (import ./services/nur-update {
                    inherit (inputs) nur-update;
                  })
                  ./build03/configuration.nix
                  inputs.srvos.nixosModules.mixins-nginx
                  inputs.srvos.nixosModules.hardware-hetzner-online-amd
                ];
            };

            "build04.nix-community.org" = nixosSystem {
              system = "aarch64-linux";
              modules =
                common
                ++ [
                  ./build04/configuration.nix
                  inputs.disko.nixosModules.disko
                ];
            };
          };
      };
}
