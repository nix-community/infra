{
  config,
  inputs,
  pkgs,
  ...
}:
{
  imports = [
    inputs.cgroup-exporter.nixosModules.default
  ];

  services.prometheus.exporters.cgroup.enable = true;

  services.telegraf.extraConfig.inputs.prometheus.urls = [
    "http://localhost:${toString config.services.prometheus.exporters.cgroup.port}/metrics"
  ];

  nix = {
    package = pkgs.nixVersions.nix_2_25;

    settings = {
      experimental-features = [
        "auto-allocate-uids"
        "cgroups"
      ];

      system-features = [ "uid-range" ];

      auto-allocate-uids = true;
      use-cgroups = true;
    };
  };
}
