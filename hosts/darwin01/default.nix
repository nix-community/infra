{ inputs, ... }:

{
  imports = [
    inputs.self.darwinModules.community-builder
  ];

  nix.settings.max-jobs = 10;

  nixCommunity.darwin.ipv6 = "2a01:4f8:d1:5716::2 64 2a01:4f8:d1:5716::1";

  nix.settings.sandbox = "relaxed";
  nix.settings.extra-platforms = [ "x86_64-darwin" ];

  # disable nixos-tests
  nix.settings.system-features = [ "big-parallel" ];

  system.stateVersion = 5;
}
