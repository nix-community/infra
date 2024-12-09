{ inputs, ... }:

{
  imports = [
    #inputs.self.darwinModules.ci-builder
    #inputs.self.darwinModules.hercules-ci
    #inputs.self.darwinModules.remote-builder
  ];

  nix.settings.max-jobs = 10;

  nixCommunity.darwin.ipv6 = "?";

  nix.settings.sandbox = "relaxed";
  nix.settings.extra-platforms = [ "x86_64-darwin" ];

  # disable nixos-tests
  nix.settings.system-features = [ "big-parallel" ];

  system.stateVersion = 5;
}
