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
    version = "1.34.4";
    subPackages = [ "cmd/telegraf" ];
    src = pkgs.fetchFromGitHub {
      owner = "influxdata";
      repo = "telegraf";
      rev = "v${version}";
      hash = "sha256-oFhSCBGS8brXBxUiuXTCQiwRWuLvjDPte2Zi6BwelJs=";
    };
    env.CGO_ENABLED = 0;
    vendorHash = "sha256-C4p+dZkudSIJI4036RR5J8rokEUB1Vi+xTC6Ijf9gUc=";
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
