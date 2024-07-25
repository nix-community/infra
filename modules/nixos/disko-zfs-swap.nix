{
  config,
  inputs,
  lib,
  ...
}:
let
  devices = idx: {
    type = "disk";
    device = "/dev/nvme${idx}n1";
    content = {
      type = "gpt";
      partitions = lib.mkIf (idx == "0") {
        boot = {
          size = "1M";
          type = "EF02"; # for grub MBR
        };
        ESP = lib.mkIf (idx == "0") {
          size = "1G";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = [ "nofail" ];
          };
        };
        swap = {
          size = "${toString (config.nixCommunity.disko.swapSize / 2)}G";
          content = {
            type = "swap";
          };
        };
        zfs = {
          size = "100%";
          content = {
            type = "zfs";
            pool = "zroot";
          };
        };
      };
    };
  };
in
{
  imports = [ inputs.disko.nixosModules.disko ];

  options = {
    nixCommunity.disko.swapSize = lib.mkOption {
      type = lib.types.int;
      default = null;
      description = "swap size in GB";
    };
  };

  config = {
    # this is both efi and bios compatible
    boot.loader.grub = {
      enable = true;
      efiSupport = true;
      efiInstallAsRemovable = true;
    };

    # Sometimes fails after the first try, with duplicate pool name errors
    boot.initrd.systemd.services.zfs-import-zroot.serviceConfig.Restart = "on-failure";

    disko.devices = {
      disk = {
        x = devices "0";
        y = devices "1";
      };
      zpool = {
        zroot = {
          type = "zpool";
          options = {
            ashift = "12";
          };
          rootFsOptions = {
            acltype = "posixacl";
            atime = "off";
            compression = "lz4";
            mountpoint = "none";
            xattr = "sa";
            "com.sun:auto-snapshot" = "false";
          };
          datasets = {
            root = {
              type = "zfs_fs";
              mountpoint = "/";
              options.mountpoint = "legacy";
            };
          };
        };
      };
    };
  };
}
