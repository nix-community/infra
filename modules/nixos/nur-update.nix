{
  config,
  inputs,
  pkgs,
  ...
}:

{
  services.nginx.virtualHosts."nur-update.nix-community.org" = {
    locations."/".proxyPass = "http://unix:/run/nur-update/gunicorn.sock";
  };

  age.secrets.nur-update-github-token = {
    file = "${inputs.self}/secrets/nur-update-github-token.age";
  };

  systemd.services.nur-update =
    let
      python = pkgs.python3.withPackages (
        ps: with ps; [
          (ps.toPythonModule inputs.nur-update.packages.${pkgs.system}.default)
          gunicorn
        ]
      );
    in
    {
      description = "nur-update";
      script = ''
        GITHUB_TOKEN="$(<$CREDENTIALS_DIRECTORY/github-token)" \
          ${python}/bin/gunicorn nur_update:app \
          --bind unix:/run/nur-update/gunicorn.sock \
          --log-level info \
          --timeout 30 \
          --workers 3
      '';
      serviceConfig = {
        DynamicUser = true;
        LoadCredential = [ "github-token:${config.age.secrets.nur-update-github-token.path}" ];
        Restart = "always";
        RuntimeDirectory = "nur-update";
      };
      wantedBy = [ "multi-user.target" ];
    };
}
