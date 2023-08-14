{ pkgs, ... }:
{
  services.prometheus = {
    enable = true;
    ruleFiles = [
      (pkgs.writeText "prometheus-rules.yml" (builtins.toJSON {
        groups = [
          {
            name = "alerting-rules";
            rules = import ./alert-rules.nix { inherit (pkgs) lib; };
          }
        ];
      }))
    ];
    webExternalUrl = "https://prometheus.nix-community.org";
    scrapeConfigs = [
      {
        job_name = "telegraf";
        scrape_interval = "60s";
        metrics_path = "/metrics";
        static_configs =
          let
            hosts = import ./hosts.nix;
          in
          [
            {
              targets = map (host: "${host}:9273") hosts ++ [ "localhost:9273" ];
              labels.org = "nix-community";
            }
          ];
      }
    ];
    alertmanagers = [
      {
        static_configs = [
          {
            targets = [ "localhost:9093" ];
          }
        ];
      }
    ];
  };

  services.telegraf.extraConfig.inputs.prometheus.urls = [
    "http://localhost:9090/metrics" # prometheus
    "http://localhost:9093/metrics" # alertmanager
  ];

  services.nginx.virtualHosts."prometheus.nix-community.org" = {
    enableACME = true;
    forceSSL = true;
    locations."/".proxyPass = "http://localhost:9090";
  };

  services.prometheus.alertmanager = {
    enable = true;
    webExternalUrl = "https://alertmanager.nix-community.org";
    listenAddress = "[::1]";
    configuration = {
      route = {
        receiver = "default";
        routes = [
          {
            group_by = [ "host" ];
            group_wait = "5m";
            group_interval = "5m";
            repeat_interval = "4h";
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
        {
          name = "default";
        }
      ];
    };
  };

  services.nginx.virtualHosts."alertmanager.nix-community.org" = {
    enableACME = true;
    forceSSL = true;
    locations."/".proxyPass = "http://localhost:9093";
  };
}
