{ lib, inputs, ... }:
{
  flake.darwinConfigurations.mac01 = inputs.darwin.lib.darwinSystem {
    inherit inputs;
    system = "aarch64-darwin";

    modules = [ ./configuration.nix ];
  };
}
