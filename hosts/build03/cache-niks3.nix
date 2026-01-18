{ config, inputs, ... }:
# test via buildbot first, then enable odic for github actions
{
  imports = [
    inputs.niks3.nixosModules.niks3
  ];

  sops.secrets.niks3-api-token = { };
  sops.secrets.niks3-s3-access-key = { };
  sops.secrets.niks3-s3-secret-key = { };
  sops.secrets.niks3-signing-key = { };

  services.niks3 = {
    enable = true;
    httpAddr = "127.0.0.1:5751";

    cacheUrl = "https://cache.nix-community.org";

    nginx = {
      enable = true;
      domain = "niks3.nix-community.org";
    };

    s3 = {
      endpoint = "";
      bucket = "cache";
      useSSL = true;
      accessKeyFile = config.sops.secrets.niks3-s3-access-key.path;
      secretKeyFile = config.sops.secrets.niks3-s3-secret-key.path;
    };

    apiTokenFile = config.sops.secrets.niks3-api-token.path;
    signKeyFiles = [ config.sops.secrets.niks3-signing-key.path ];

    #oidc.providers.github = {
    #  issuer = "https://token.actions.githubusercontent.com";
    #  audience = "https://niks3.nix-community.org";
    #  boundClaims = {
    #    repository_owner = [ "nix-community" ];
    #  };
    #};
  };
}
