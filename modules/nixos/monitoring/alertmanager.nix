{
  services.telegraf.extraConfig.inputs.prometheus.urls = [
    "http://localhost:9093/metrics"
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
