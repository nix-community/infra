{ pkgs, config, ... }:

let
  domain = "lemmy.nix-community.org";
in
{
  sops.secrets.pictrs-env = { };
  sops.secrets.lemmy-pictrsapikeyfile = { };

  services.telegraf.extraConfig.inputs.prometheus.urls = [ "http://localhost:10002/metrics" ];

  services.lemmy = {
    enable = true;
    server.package = pkgs.lemmy-server.overrideAttrs (_: { cargoBuildFeatures = [ "prometheus-metrics" ]; });
    nginx.enable = true;
    database.createLocally = true;
    pictrsApiKeyFile = config.sops.secrets.lemmy-pictrsapikeyfile.path;

    settings = {
      hostname = domain;
      pictrs = {
        url = with config.services.pict-rs; "http://${address}:${toString port}";
      };
    };
  };

  services.nginx.virtualHosts.${domain} = {
    enableACME = true;
    forceSSL = true;
  };

  # Lemmy image storage
  services.pict-rs = {
    enable = true;
    package = pkgs.pict-rs; # Use 0.4.0+ despite stateVersion
    storePath = "/mnt/lemmy-pict-rs";
    repoPath = "/var/lib/pict-rs/sled";
  };
  systemd.services.pict-rs.unitConfig.RequiresMountsFor = [ "/mnt/lemmy-pict-rs" ];
  systemd.services.pict-rs.serviceConfig.EnvironmentFile = [
    config.sops.secrets.pictrs-env.path
  ];

  # Pict-rs uses DynamicUser
  systemd.services.pict-rs.serviceConfig.ReadWritePaths = "/mnt/lemmy-pict-rs";
}
