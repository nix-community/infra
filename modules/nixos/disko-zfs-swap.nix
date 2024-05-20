{ config, inputs, lib, ... }:
let
  devices = idx: {
    type = "disk";
    device = "/dev/nvme${idx}n1";
    content = {
      type = "gpt";
      partitions = {
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
  imports = [
    inputs.disko.nixosModules.disko
    inputs.srvos.nixosModules.mixins-systemd-boot
  ];

  options = {
    nixCommunity.disko.swapSize = lib.mkOption {
      type = lib.types.int;
      default = null;
      description = "swap size in GB";
    };
  };

  config = {
    networking.hostId = "deadbeef";

    # Only enable during install
    boot.loader.efi.canTouchEfiVariables = true;

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
