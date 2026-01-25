{ config, inputs, ... }:
{
  imports = [ inputs.disko.nixosModules.disko ];

  # this is both efi and bios compatible
  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  # the default zpool import services somehow times out while this import works fine?
  boot.initrd.systemd.services.zfs-import-zroot.serviceConfig.ExecStartPre =
    "${config.boot.zfs.package}/bin/zpool import -N -f zroot";

  # Sometimes fails after the first try, with duplicate pool name errors
  boot.initrd.systemd.services.zfs-import-zroot.serviceConfig.Restart = "on-failure";

  disko.devices = {
    disk = {
      nvme0n1 = {
        type = "disk";
        device = "/dev/nvme0n1";
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
      nvme1n1 = {
        type = "disk";
        device = "/dev/nvme1n1";
        content = {
          type = "gpt";
          partitions = {
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
    };
    zpool = {
      zroot = {
        type = "zpool";
        options = {
          ashift = "12";
        };
        rootFsOptions = {
          acltype = "posix";
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
          build = {
            type = "zfs_fs";
            mountpoint = "/nix/var/nix/builds";
            options.mountpoint = "legacy";
            options.sync = "disabled";
          };
          tmp = {
            type = "zfs_fs";
            mountpoint = "/tmp";
            options.mountpoint = "legacy";
            options.sync = "disabled";
          };
        };
      };
    };
  };
}
