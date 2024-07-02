{ config, inputs, ... }:
{
  imports = [
    inputs.srvos.nixosModules.hardware-hetzner-online-arm
    inputs.self.nixosModules.disko-zfs
    inputs.self.nixosModules.common
    inputs.self.nixosModules.builder
    inputs.self.nixosModules.hercules-ci
    inputs.self.nixosModules.remote-builder
  ];

  nixCommunity.remote-builder.key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEmdo1x1QkRepZf7nSe+OdEWX+wOjkBLF70vX9F+xf68 builder";

  networking.hostName = "build04";

  system.stateVersion = "23.11";

  networking.domains.baseDomains."${config.networking.domain}" = {
    a.data = "65.109.107.32";
    aaaa.data = "2a01:4f9:3051:3962::2";
  };

  systemd.network.networks."10-uplink".networkConfig.Address = "2a01:4f9:3051:3962::2";
}
