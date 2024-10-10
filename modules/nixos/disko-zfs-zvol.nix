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
      partitions = {
        boot = lib.mkIf (idx == "0") {
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
    nixCommunity.disko.zramWritebackSize = lib.mkOption {
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

    zramSwap.writebackDevice = "/dev/zvol/zroot/writeback";

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
            writeback = {
              type = "zfs_volume";
              size = "${toString (config.nixCommunity.disko.zramWritebackSize)}G";
            };
          };
        };
      };
    };
  };
}
