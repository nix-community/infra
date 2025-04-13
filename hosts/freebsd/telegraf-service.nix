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

  package = pkgs.buildGo124Module rec {
    pname = "telegraf";
    version = "1.34.0";
    subPackages = [ "cmd/telegraf" ];
    src = pkgs.fetchFromGitHub {
      owner = "influxdata";
      repo = "telegraf";
      rev = "v${version}";
      hash = "sha256-0l2x/ljKcEBkyxKbeYtRpBGMSKVbKe5UKNHaNJZt2fI=";
    };
    env.CGO_ENABLED = 0;
    vendorHash = "sha256-juuC2iM6/w1VA7afkA3qA9r39+z4tcqwVlV54jFOCuw=";
    proxyVendor = true;
    ldflags = [
      "-s"
      "-w"
      "-X=github.com/influxdata/telegraf/internal.Commit=${src.rev}"
      "-X=github.com/influxdata/telegraf/internal.Version=${version}"
    ];
  };
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
