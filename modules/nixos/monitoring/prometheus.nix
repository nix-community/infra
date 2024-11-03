{ inputs, pkgs, ... }:
{
  systemd.services.prometheus.after = pkgs.lib.mkForce [ "network-online.target" ];
  systemd.services.prometheus.wants = [ "network-online.target" ];
  systemd.services.alertmanager.after = [ "prometheus.service" ];

  services.prometheus = {
    enable = true;
    checkConfig = true;
    webExternalUrl = "https://monitoring.nix-community.org/prometheus/";
    extraFlags = [
      "--storage.tsdb.retention.time=30d"
      "--web.route-prefix=/"
    ];
    scrapeConfigs = [
      {
        job_name = "telegraf";
        scrape_interval = "60s";
        metrics_path = "/metrics";
        static_configs =
          let
            hosts = (import "${inputs.self}/modules/shared/known-hosts.nix").programs.ssh.knownHosts;
          in
          [
            {
              targets = builtins.concatMap (host: map (name: "${name}:9273") host.hostNames) (
                builtins.attrValues hosts
              );
              labels.org = "nix-community";
            }
          ];
      }
    ];
    alertmanagers = [ { static_configs = [ { targets = [ "localhost:9093" ]; } ]; } ];
  };

  services.telegraf.extraConfig.inputs.prometheus.urls = [
    "http://localhost:9090/metrics" # prometheus
    "http://localhost:9093/metrics" # alertmanager
  ];

  services.prometheus.alertmanager = {
    enable = true;
    webExternalUrl = "https://monitoring.nix-community.org/alertmanager/";
    listenAddress = "[::1]";
    extraFlags = [
      "--cluster.listen-address=''"
      "--web.route-prefix=/"
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
