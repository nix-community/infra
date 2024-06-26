{ inputs, ... }:
{
  imports = [
    ({ lib, flake-parts-lib, ... }:
      flake-parts-lib.mkTransposedPerSystemModule {
        name = "topology";
        file = ./topology.nix;
        option = lib.mkOption {
          type = lib.types.unspecified;
        };
      })
  ];

  perSystem = { system, ... }: {
    topology = import inputs.nix-topology {
      pkgs = import inputs.nixpkgs {
        inherit system;
        overlays = [
          inputs.nix-topology.overlays.default
        ];
      };
      modules = [
        { inherit (inputs.self) nixosConfigurations; }
      ];
    };
  };
}
