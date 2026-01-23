{
  config,
  lib,
  pkgs,
  ...
}:
{
  # adapted from:
  # https://github.com/NixOS/nixpkgs/blob/93cda47a1f2049c70074367445e6fb2bfb928154/nixos/modules/system/activation/switchable-system.nix

  options.nixCommunity.boot-compare = lib.mkOption {
    type = lib.types.listOf lib.types.pathInStore;
  };

  config = {
    system.build.boot-compare = pkgs.writeTextFile {
      name = "boot-compare";
      text = lib.concatMapStringsSep "\n" (drv: drv.outPath) config.nixCommunity.boot-compare;
    };

    system.systemBuilderCommands = ''
      ln -s ${config.system.build.boot-compare} $out/boot-compare
    '';

    nixCommunity.boot-compare =
      let
        fstab = pkgs.writeTextFile {
          name = "etc/fstab";
          inherit (config.environment.etc.fstab) text;
        };
        kernel-params = pkgs.writeTextFile {
          name = "kernel-params";
          text = pkgs.lib.concatStringsSep " " config.boot.kernelParams;
        };
      in
      # TODO: include config.system.build.inhibitSwitch ?
      [
        config.system.build.initialRamdisk
        config.system.build.kernel
        config.system.modulesTree
        fstab
        kernel-params
      ]
      ++ lib.optionals (lib.hasPrefix "build" config.networking.hostName) [ config.hardware.firmware ];
  };
}
