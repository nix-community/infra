{ inputs, ... }:
{
  imports = [
    inputs.self.nixosModules.ci-builder
    inputs.self.nixosModules.disko-zfs-systemd-boot
    inputs.self.nixosModules.hercules-ci
    inputs.srvos.nixosModules.hardware-hetzner-online-arm
  ];

  nix.settings.max-jobs = 80;

  system.stateVersion = "23.11";

  systemd.network.networks."10-uplink".networkConfig.Address = "2a01:4f9:3051:3962::2";
}
