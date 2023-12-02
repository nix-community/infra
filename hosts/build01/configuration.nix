{ inputs, ... }:
# Boot recovery:
# Activate 64-bit Rescue system in https://robot.your-server.de/server
# ssh root@build01.nix-community.org "mount /dev/md[0-9]* /mnt && /mnt/kexec_bundle"
#
#
# In kexec image:
# # stop autoreboot
# $ systemctl stop autoreboot.timer
# $ zpool import -f zroot && mount -t zfs zroot/root /mnt && mount -t zfs zroot/root/home /mnt/home && mount -t zfs zroot/root/nix /mnt/nix && mount /dev/md[0-9]* /mnt/boot
# nixos-enter
{
  imports = [
    inputs.srvos.nixosModules.hardware-hetzner-online-amd
    inputs.self.nixosModules.common
    inputs.self.nixosModules.builder
    inputs.self.nixosModules.zfs
    inputs.self.nixosModules.community-builder
  ];

  # Emulate riscv64 until we have proper builders
  boot.binfmt.emulatedSystems = [ "riscv64-linux" ];

  # /boot is a mirror raid
  boot.loader.grub.devices = [ "/dev/sda" "/dev/sdb" ];
  boot.loader.grub.enable = true;
  boot.swraid.enable = true;
  boot.loader.grub.extraConfig = "insmod mdraid1x";

  networking.hostName = "build01";
  networking.hostId = "d2905767";

  systemd.network.networks."10-uplink".networkConfig.Address = "2a01:4f9:3a:3b16::1/64";

  system.stateVersion = "23.11";
}
