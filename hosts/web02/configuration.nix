{ inputs, ... }:
{
  imports = [
    ./gandi.nix
    inputs.self.nixosModules.common
    inputs.self.nixosModules.monitoring
    inputs.srvos.nixosModules.mixins-nginx
  ];

  networking.hostName = "web02";

  networking.useDHCP = true;

  # enabled by default for stateVersion < 23.11
  boot.swraid.enable = false;
}
