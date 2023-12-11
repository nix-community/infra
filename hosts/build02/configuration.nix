{ inputs, ... }:

{
  imports = [
    inputs.srvos.nixosModules.mixins-nginx
    inputs.srvos.nixosModules.hardware-hetzner-online-amd
    inputs.self.nixosModules.common
    inputs.self.nixosModules.builder
    inputs.self.nixosModules.disko-raid
  ];

  networking.hostName = "build02";
  networking.hostId = "af9ccc71";
  networking.nameservers = [ "1.1.1.1" "1.0.0.1" ];

  systemd.network.networks."10-uplink".networkConfig.Address = "?";

  system.stateVersion = "23.11";
}
