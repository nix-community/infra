{
  config,
  inputs,
  lib,
  ...
}:
{
  services.telegraf.extraConfig.inputs.prometheus.urls = [
    "http://localhost:8428/metrics"
    "http://localhost:8880/metrics"
  ];

  services.vmalert.instances.vm = {
    enable = true;
    settings = {
      "datasource.url" = "http://localhost:8428";
      "remoteRead.url" = "http://localhost:8428";
      "remoteWrite.url" = "http://localhost:8428";
      "external.url" = "https://victoriametrics.nix-community.org";
      "httpListenAddr" = "127.0.0.1:8880";
      "notifier.url" = [ "http://localhost:9093" ];
      rule = config.services.prometheus.ruleFiles;
    };
  };

  services.victoriametrics = {
    enable = true;
    extraOptions = [
      "-vmalert.proxyURL=http://127.0.0.1:8880"
    ];
    retentionPeriod = "30d";
    prometheusConfig = {
      scrape_configs = [
        (import ./scrape-configs.nix { inherit inputs lib; })
      ];
    };
  };
}
