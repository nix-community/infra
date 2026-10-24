{
  config,
  inputs,
  lib,
  ...
}:
{
  systemd.services.prometheus.after = lib.mkForce [ "network-online.target" ];
  systemd.services.prometheus.wants = [ "network-online.target" ];
  systemd.services.alertmanager.after = [ config.systemd.services.prometheus.name ];

  services.prometheus = {
    enable = true;
    checkConfig = true;
    webExternalUrl = "https://prometheus.nix-community.org/";
    extraFlags = [
      "--storage.tsdb.retention.time=30d"
    ];
    scrapeConfigs = [
      (import ./scrape-configs.nix { inherit inputs lib; })
    ];
    alertmanagers = [ { static_configs = [ { targets = [ "localhost:9093" ]; } ]; } ];
  };

  services.telegraf.extraConfig.inputs.prometheus.urls = [
    "http://localhost:9090/metrics" # prometheus
    "http://localhost:9093/metrics" # alertmanager
  ];

  services.prometheus.alertmanager = {
    enable = true;
    webExternalUrl = "https://alertmanager.nix-community.org/";
    listenAddress = "127.0.0.1";
    extraFlags = [
      "--cluster.listen-address=''"
    ];
    configuration = {
      route = {
        receiver = "default";
        routes = [
          {
            group_by = [ "host" ];
            group_wait = "5m";
            group_interval = "5m";
            repeat_interval = "12h";
            receiver = "nix-community";
          }
        ];
      };
      receivers = [
        {
          name = "nix-community";
          webhook_configs = [
            {
              url = "http://localhost:9088/alert";
              max_alerts = 5;
            }
          ];
        }
        { name = "default"; }
      ];
    };
  };
}
