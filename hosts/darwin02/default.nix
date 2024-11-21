{ inputs, ... }:

{
  imports = [
    inputs.self.darwinModules.ci-builder
    inputs.self.darwinModules.hercules-ci
    inputs.self.darwinModules.remote-builder
  ];

  nixCommunity.darwin.ipv6 = "2a09:9340:808:60b::1 64 fe80::1";

  nix.settings.sandbox = "relaxed";
  nix.settings.extra-platforms = [ "x86_64-darwin" ];

  # disable nixos-tests
  nix.settings.system-features = [ "big-parallel" ];

  system.stateVersion = 4;
}
