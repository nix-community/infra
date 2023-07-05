{ inputs, ... }:
{
  imports = [
    inputs.disko.nixosModules.disko
    ./hardware-configuration.nix
    inputs.srvos.nixosModules.mixins-nginx
    inputs.srvos.nixosModules.hardware-hetzner-cloud
    inputs.self.nixosModules.common
    ./samba.nix
  ];

  networking.hostName = "web01";
  networking.hostId = "1cfd5aa3";

  system.stateVersion = "23.05";
}
