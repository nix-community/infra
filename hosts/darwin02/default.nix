{ inputs, ... }:

{
  imports = [
    inputs.self.darwinModules.ci-builder
    # remotePlatformsWithSameFeatures is enabled on build03
    # https://github.com/NixOS/nixpkgs/issues/461651#issuecomment-3536203369
    # inputs.self.darwinModules.hercules-ci
    inputs.self.darwinModules.remote-builder
  ];

  nix.settings.max-jobs = 10;

  nixCommunity.darwin.ipv6 = "2a01:4f8:d1:5715::2 64 2a01:4f8:d1:5715::1";

  nix.settings.sandbox = "relaxed";
  nix.settings.extra-platforms = [ "x86_64-darwin" ];

  # disable nixos-tests
  nix.settings.system-features = [ "big-parallel" ];

  system.stateVersion = 5;
}
