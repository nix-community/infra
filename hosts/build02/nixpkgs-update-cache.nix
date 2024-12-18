{ config, ... }:
{
  # nixpkgs-update-cache.nix-community.org-1:U8d6wiQecHUPJFSqHN9GSSmNkmdiFW7GW7WNAnHW0SM=

  sops.secrets.harmonia-key = { };

  services.harmonia = {
    enable = true;
    signKeyPaths = [ config.sops.secrets.harmonia-key.path ];
  };

  services.nginx.virtualHosts."nixpkgs-update-cache.nix-community.org" = {
    locations."/" = {
      extraConfig = ''
        proxy_pass http://127.0.0.1:5000;
        proxy_set_header Host $host;
        proxy_redirect http:// https://;
        proxy_http_version 1.1;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection $connection_upgrade;
      '';
    };
  };
}
