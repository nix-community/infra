{ disks ? [ ], ... }:
let
  content = {
    format = "gpt";
    type = "table";
    partitions = [
      {
        name = "boot";
        start = "0";
        end = "1M";
        part-type = "primary";
        flags = [ "bios_grub" ];
      }
      {
        name = "mdadm";
        start = "1M";
        end = "2G";
        content = {
          name = "boot";
          type = "mdraid";
        };
      }
      {
        name = "zfs";
        start = "2G";
        end = "-16G";
        content = {
          pool = "zroot";
          type = "zfs";
        };
      }
      {
        name = "swap";
        start = "-16G";
        end = "100%";
        part-type = "primary";
        content = {
          type = "swap";
        };
      }
    ];
  };
in
{
  disk = {
    disk0 = {
      device = builtins.elemAt disks 0;
      type = "disk";
      inherit content;
    };
    disk1 = {
      device = builtins.elemAt disks 1;
      type = "disk";
      inherit content;
    };
  };
  mdadm = {
    boot = {
      type = "mdadm";
      level = 1;
      metadata = "1.0";
      content = {
        type = "filesystem";
        format = "ext4";
        mountOptions = [ "nofail" ];
        mountpoint = "/boot";
      };
    };
  };
  zpool = {
    zroot = {
      type = "zpool";
      rootFsOptions = {
        acltype = "posixacl";
        atime = "off";
        compression = "lz4";
        xattr = "sa";
        "com.sun:auto-snapshot" = "false";
      };

      datasets = {
        "root" = {
          type = "zfs_fs";
          mountpoint = null;
        };
        "root/nixos" = {
          type = "zfs_fs";
          mountpoint = "/";
        };
        "root/home" = {
          type = "zfs_fs";
          mountpoint = "/home";
          mountOptions = [ "nofail" ];
        };
      };
    };
  };
}
