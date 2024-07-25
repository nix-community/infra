{ config, inputs, ... }:
{
  imports = [
    inputs.srvos.nixosModules.hardware-hetzner-online-amd
    inputs.self.nixosModules.common
    inputs.self.nixosModules.disko-zfs
    inputs.self.nixosModules.builder
    inputs.self.nixosModules.community-builder
  ];

  # the default zpool import services somehow times out while this import works fine?
  boot.initrd.systemd.services.zfs-import-zroot.serviceConfig.ExecStartPre = "${config.boot.zfs.package}/bin/zpool import -N -f zroot";

  # Emulate riscv64 until we have proper builders
  boot.binfmt.emulatedSystems = [ "riscv64-linux" ];

  networking.hostName = "build01";

  systemd.network.networks."10-uplink".networkConfig.Address = "2a01:4f9:3a:3b16::1/64";

  system.stateVersion = "23.11";
}
