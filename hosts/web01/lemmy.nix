_:

let
  domain = "lemmy.nix-community.org";
in
{
  services.lemmy = {
    enable = true;
    nginx.enable = true;
    database.createLocally = true;

    settings = {
      hostname = domain;
    };
  };

  services.nginx.virtualHosts.${domain} = {
    enableACME = true;
    forceSSL = true;
  };

  # Lemmy image storage
  services.pict-rs = {
    enable = true;
    dataDir = "/mnt/lemmy-pict-rs";
  };

  # Pict-rs uses DynamicUser
  systemd.services.pict-rs.serviceConfig.ReadWritePaths = "/mnt/lemmy-pict-rs";
}
