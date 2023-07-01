{ inputs, ... }:
{
  # Boot recovery:
  # Activate 64-bit Rescue system in https://robot.your-server.de/server
  # ssh root@build03.nix-community.org "mount /dev/md[0-9]* /mnt && /mnt/kexec_bundle"
  #
  # In kexec image:
  # stop autoreboot:
  # $ systemctl stop autoreboot.timer
  # $ zpool import -f zroot && mount -t zfs zroot/root/nixos /mnt && mount -t zfs zroot/root/home /mnt/home && mount /dev/md[0-9]* /mnt/boot
  # $ nixos-enter
  imports = [
    inputs.srvos.nixosModules.mixins-nginx
    inputs.srvos.nixosModules.hardware-hetzner-online-amd
    inputs.self.nixosModules.common
    inputs.self.nixosModules.hercules-ci
    inputs.self.nixosModules.raid
    inputs.self.nixosModules.watch-store
    inputs.self.nixosModules.zfs
    inputs.self.nixosModules.remote-builder-build04
    inputs.self.nixosModules.remote-builder-darwin02

    inputs.self.nixosModules.hydra
    inputs.self.nixosModules.nur-update
  ];

  # /boot is a mirror raid
  boot.loader.grub.devices = [ "/dev/nvme0n1" "/dev/nvme1n1" ];
  boot.loader.grub.enable = true;

  systemd.network.networks."10-uplink".networkConfig.Address = "2a01:4f9:3a:3b16::1/64";

  networking.hostName = "build03";
  networking.hostId = "8daf74c0";

  system.stateVersion = "21.05";
}
