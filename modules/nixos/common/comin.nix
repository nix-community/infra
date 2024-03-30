{ inputs, lib, ... }:
{
  imports = [
    inputs.comin.nixosModules.comin
  ];

  services.telegraf.extraConfig.inputs.prometheus.urls = [
    "http://localhost:4243/metrics"
  ];

  services.telegraf.extraConfig.inputs.http = {
    urls = [ "http://localhost:4242/status" ];
    data_format = "json";
    name_override = "comin";
  };

  services.comin = {
    enable = lib.mkDefault false;
    remotes = [
      {
        url = "https://github.com/nix-community/infra.git";
        name = "origin";
        poller.period = 300; # every 5 minutes
        branches.main.name = "master";
        branches.testing.name = ""; # disable testing branch
      }
    ];
  };
}
