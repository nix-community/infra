{ lib, ... }:
let
  mirrorBoot = idx: {
    type = "disk";
    device = "/dev/nvme${idx}n1";
    content = {
      type = "gpt";
      partitions = {
        boot = {
          size = "1M";
          type = "EF02"; # for grub MBR
        };
        ESP = {
          size = "1G";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot${idx}";
            mountOptions = [ "nofail" ];
          };
        };
        raid-root = {
          size = "100%";
          content = {
            type = "mdraid";
            name = "root";
          };
        };
      };
    };
  };
in
{
  # this is both efi and bios compatible
  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    efiInstallAsRemovable = true;
    devices = lib.mkForce [ ]; # disko adds /boot here, we want /boot0 /boot1
    mirroredBoots = [
      { path = "/boot0"; devices = [ "/dev/nvme0n1" ]; }
      { path = "/boot1"; devices = [ "/dev/nvme1n1" ]; }
    ];
  };

  disko.devices = {
    disk = {
      x = mirrorBoot "0";
      y = mirrorBoot "1";
    };
    mdadm.root = {
      type = "mdadm";
      level = 1;
      content = {
        type = "filesystem";
        format = "ext4";
        mountpoint = "/";
      };
    };
  };
}
