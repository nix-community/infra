{
  config,
  lib,
  pkgs,
  ...
}:
{
  # https://github.com/NixOS/nixpkgs/pull/473282

  options.system.switch.inhibitors = lib.mkOption {
    type = lib.types.listOf lib.types.pathInStore;
    default = [ ];
  };

  config.system = {
    switch.inhibitors = [
      config.systemd.package
    ];

    systemBuilderCommands = ''
      ln -s ${config.system.build.inhibitSwitch} $out/switch-inhibitors
    '';

    build.inhibitSwitch = pkgs.writeTextFile {
      name = "switch-inhibitors";
      text = lib.concatMapStringsSep "\n" (drv: drv.outPath) config.system.switch.inhibitors;
    };
  };
}
