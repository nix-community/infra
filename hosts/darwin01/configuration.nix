{ inputs, ... }:

{
  imports = [
    inputs.self.darwinModules.common
    inputs.self.darwinModules.builder
    inputs.self.darwinModules.community-builder
  ];

  nix.settings.sandbox = false;
  nix.settings.extra-platforms = [ "x86_64-darwin" ];

  # disable nixos-tests
  nix.settings.system-features = [ "big-parallel" ];

  networking.hostName = "darwin01";

  system.stateVersion = 4;
}
