{ inputs, ... }:

{
  imports = [
    inputs.self.darwinModules.ci-builder
    inputs.self.darwinModules.hercules-ci
    inputs.self.darwinModules.remote-builder
  ];

  nixCommunity.hydra-queue-builder-v2 = {
    maxJobs = 1;
  };

  nix.settings.max-jobs = 10;

  nixCommunity.darwin.ipv6 = "2a01:4f8:d1:5715::2 64 2a01:4f8:d1:5715::1";

  nix.settings.sandbox = "relaxed";
  nix.settings.extra-platforms = [ "x86_64-darwin" ];

  # disable nixos-tests
  nix.settings.system-features = [ "big-parallel" ];

  system.stateVersion = 5;
}
