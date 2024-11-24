{ config, inputs, ... }:
{
  age.secrets.oauth2-proxy-key-file = {
    file = "${inputs.self}/secrets/oauth2-proxy-key-file.age";
    owner = "oauth2-proxy";
  };

  # https://oauth2-proxy.github.io/oauth2-proxy/configuration/providers/github
  services.oauth2-proxy = {
    enable = true;
    provider = "github";
    github = {
      org = "nix-community";
      team = "admin";
    };
    clientID = "Ov23liKOQPREko8sCk6F";
    keyFile = config.age.secrets.oauth2-proxy-key-file.path;
    nginx.domain = "alertmanager.nix-community.org";
    nginx.virtualHosts = {
      "alertmanager.nix-community.org" = { };
    };
    email.domains = [ "*" ];
  };
}
