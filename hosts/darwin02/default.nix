{ inputs, ... }:

{
  imports = [
    inputs.self.darwinModules.ci-builder
    inputs.self.darwinModules.remote-builder
  ];

  nix.settings.max-jobs = 10;

  nixCommunity.darwin.ipv6 = "2a01:4f8:d1:5715::2 64 2a01:4f8:d1:5715::1";

  system.stateVersion = 5;
}
