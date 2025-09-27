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

  boot.loader.systemd-boot.enable = true;

  # the default zpool import services somehow times out while this import works fine?
  boot.initrd.systemd.services.zfs-import-zroot.serviceConfig.ExecStartPre =
    "${config.boot.zfs.package}/bin/zpool import -N -f zroot";

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
          };
        };
      };
    };
  };
}
