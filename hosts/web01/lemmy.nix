{ pkgs, config, ... }:

let
  domain = "lemmy.nix-community.org";
in
{
  sops.secrets.pictrs-env = { };
  sops.secrets.lemmy-pictrsapikeyfile = { };

  services.lemmy = {
    enable = true;
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

  systemd.services.lemmy.unitConfig.Upholds = [ "pict-rs.service" ];

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
