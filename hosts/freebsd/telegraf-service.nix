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
    init.services.telegraf = {
      description = "Telegraf Agent";
      dependencies = [ "NETWORKING" ];

      startType = "foreground";
      startCommand = [
        "${pkgs.telegraf}/bin/telegraf"
        "--config"
        "${configFile}"
      ];
    };
  };
}
