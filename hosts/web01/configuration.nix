{ inputs, ... }:
{
  imports = [
    inputs.disko.nixosModules.disko
    ./hardware-configuration.nix
    inputs.srvos.nixosModules.mixins-nginx
    inputs.srvos.nixosModules.hardware-hetzner-cloud
    inputs.self.nixosModules.common
    ./samba.nix
    ./postgresql.nix
    ./pgbackrest.nix
    ./lemmy.nix
  ];

  networking.hostName = "web01";
  networking.hostId = "1cfd5aa3";

  system.stateVersion = "23.05";

  # enabled by default for stateVersion < 23.11
  boot.swraid.enable = false;
}
