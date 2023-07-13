{ inputs, pkgs, lib, config, ... }:

let
  domain = "lemmy.nix-community.org";
in
{
  sops.secrets.pictrs-env = { };
  sops.secrets.lemmy-secretfile = { };

  services.lemmy = {
    enable = true;
    nginx.enable = true;
    database.createLocally = true;
    secretFile = config.sops.secrets.lemmy-secretfile.path;

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
    dataDir = "/mnt/lemmy-pict-rs";
  };

  # In the transition from 0.3.3 to 0.4 pict-rs breaks it's previous
  # conflation of data storage and statate storage.
  # 0.4 is still not released but we need this separation already.
  # This renames the env vars set by the NixOS module.
  #
  # Migrate to using upstream NixOS definitions when 0.4 is in nixpkgs.
  systemd.services.pict-rs.serviceConfig.EnvironmentFile = [
    config.sops.secrets.pictrs-env.path
  ];
  systemd.services.pict-rs.unitConfig.RequiresMountsFor = [ "/mnt/lemmy-pict-rs" ];
  systemd.services.pict-rs.environment = {
    PICTRS__REPO__PATH = "/var/lib/pict-rs/sled";
    PICTRS__STORE__PATH = "/mnt/lemmy-pict-rs";
  };
  systemd.services.pict-rs.serviceConfig.ExecStart = lib.mkForce "${lib.getExe pkgs.pict-rs} run";
  nixpkgs.overlays = [
    (_final: _prev: {
      inherit (inputs.pict-rs.packages.x86_64-linux) pict-rs;
    })
  ];

  # Pict-rs uses DynamicUser
  systemd.services.pict-rs.serviceConfig.ReadWritePaths = "/mnt/lemmy-pict-rs";
}
