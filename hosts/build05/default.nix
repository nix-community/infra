{ inputs, ... }:
{
  imports = [
    inputs.self.nixosModules.community-builder
    inputs.self.nixosModules.disko-zfs
    inputs.srvos.nixosModules.hardware-hetzner-online-arm
  ];

  nixpkgs.hostPlatform = "aarch64-linux";

  nixCommunity.threads = 80;

  system.stateVersion = "23.11";

  systemd.network.networks."10-uplink".networkConfig.Address = "2a01:4f9:3051:5066::1";
}
