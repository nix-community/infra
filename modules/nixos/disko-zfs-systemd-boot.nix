{ inputs, lib, ... }:
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
  imports = [
    inputs.disko.nixosModules.disko
    inputs.disko-zfs.nixosModules.default
  ];

  disko.zfs = {
    enable = true;
    settings.ignoredProperties = [
      "nixos:shutdown-time"
    ];
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # suppress warning, https://github.com/NixOS/nixpkgs/commit/dfd0f18d9df417bb185d95ac806c220049fbfca1
  boot.zfs.forceImportRoot = true;

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
            options.mountpoint = "/";
          };
          build = {
            type = "zfs_fs";
            mountpoint = "/nix/var/nix/builds";
            options.mountpoint = "/nix/var/nix/builds";
            options.sync = "disabled";
          };
          tmp = {
            type = "zfs_fs";
            mountpoint = "/tmp";
            options.mountpoint = "/tmp";
            options.sync = "disabled";
          };
        };
      };
    };
  };
}
