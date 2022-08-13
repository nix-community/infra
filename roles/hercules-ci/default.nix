{ config, pkgs, ... }:
let
  herculesSecret = {
    owner = "hercules-ci-agent";
    sopsFile = ./secrets.yaml;
  };
  secrets = config.sops.secrets;
in {
  sops.secrets."binary-caches.json" = herculesSecret;
  sops.secrets."cluster-join-token.key" = herculesSecret;
  sops.secrets."hercules-secrets" = herculesSecret;

  services.hercules-ci-agent = {
    enable = true;
    settings = {
      binaryCachesPath = secrets."binary-caches.json".path;
      secretsJsonPath = secrets."hercules-secrets".path;
      clusterJoinTokenPath = secrets."cluster-join-token.key".path;
    };
  };
}
