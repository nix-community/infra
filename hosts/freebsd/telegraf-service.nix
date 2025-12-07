{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkOption;

  cfg = config.services.telegraf;

  settingsFormat = pkgs.formats.toml { };
  configFile = settingsFormat.generate "config.toml" cfg.extraConfig;

  package = pkgs.telegraf;
in
{
  options.services.telegraf = {
    enable = mkEnableOption "telegraf agent";

    extraConfig = mkOption {
      default = { };
      description = "Extra configuration options for telegraf";
      inherit (settingsFormat) type;
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ package ];

    environment.etc."telegraf/telegraf.conf".source = configFile;

    init.services.telegraf = {
      description = "Telegraf Agent";
      dependencies = [ "NETWORKING" ];

      startType = "foreground";
      startCommand = [ "${package}/bin/telegraf" ];
    };
  };
}
