{ nur-update }: { config, lib, pkgs, ... }:

{
  services.nginx.virtualHosts."nur-update.nix-community.org" = {
    enableACME = true;
    forceSSL = true;
    locations."/".proxyPass = "http://unix:/run/nur-update/gunicorn.sock";
  };

  sops.secrets.nur-update-github-token = { };

  systemd.services.nur-update = {
    description = "nur-update service";
    script = ''
      GITHUB_TOKEN="$(<$CREDENTIALS_DIRECTORY/github-token)" \
        ${lib.getExe pkgs.python3.pkgs.gunicorn} nur_update:app \
        --bind unix:/run/nur-update/gunicorn.sock \
        --log-level info \
        --python-path ${nur-update.packages.${pkgs.system}.default} \
        --timeout 30 \
        --workers 3
    '';
    serviceConfig = {
      DynamicUser = true;
      LoadCredential = [ "github-token:${config.sops.secrets.nur-update-github-token.path}" ];
      Restart = "always";
      RuntimeDirectory = "nur-update";
    };
    wantedBy = [ "multi-user.target" ];
  };
}
