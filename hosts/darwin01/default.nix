{ inputs, pkgs, ... }:

{
  imports = [
    inputs.self.darwinModules.community-builder
  ];

  nixCommunity.threads = 10;

  nixCommunity.darwin.ipv6 = "2a01:4f8:d1:5716::2 64 2a01:4f8:d1:5716::1";

  nix.settings.sandbox = "relaxed";
  nix.settings.extra-platforms = [ "x86_64-darwin" ];

  # disable nixos-tests
  nix.settings.system-features = [ "big-parallel" ];

  system.stateVersion = 5;

  # test auto-optimise-store fix
  # https://github.com/NixOS/nix/pull/13241
  nix.package = pkgs.nixVersions.nix_2_30;
  nix.optimise.automatic = false;
  nix.settings.auto-optimise-store = pkgs.lib.mkForce true;
}
