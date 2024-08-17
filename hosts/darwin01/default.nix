{ inputs, ... }:

{
  imports = [
    inputs.self.darwinModules.builder
    inputs.self.darwinModules.community-builder
  ];

  nixCommunity.darwin.ipv6 = "2a09:9340:808:630::1 64 fe80::1";

  nix.settings.sandbox = "relaxed";
  nix.settings.extra-platforms = [ "x86_64-darwin" ];

  # disable nixos-tests
  nix.settings.system-features = [ "big-parallel" ];

  system.stateVersion = 4;
}
