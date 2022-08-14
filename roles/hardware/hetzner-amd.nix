{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    "${modulesPath}/installer/scan/not-detected.nix"
  ];

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "ahci"
    # SATA ssd (only build01)
    "sd_mod"
    # NVME
    "nvme"
  ];
  boot.kernelModules = [
    "kvm-amd"
  ];

  fileSystems."/" = {
    device = "zroot/root/nixos";
    fsType = "zfs";
  };

  fileSystems."/home" = {
    device = "zroot/root/home";
    fsType = "zfs";
    # We don't want servers to go in systemd rescue mode, but rather having
    # failed mounts show up in monitoring
    options = [ "nofail" ];
  };

  fileSystems."/boot" = {
    device = "/dev/md127";
    fsType = "ext4";
    options = [ "nofail" ];
  };
}
