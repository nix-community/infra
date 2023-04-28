{ config, ... }:
let
  herculesSecret = {
    owner = "hercules-ci-agent";
    sopsFile = ./secrets.yaml;
  };
  inherit (config.sops) secrets;
in
{
  sops.secrets."binary-caches.json" = herculesSecret;
  sops.secrets."cluster-join-token.key" = herculesSecret;
  sops.secrets."hercules-secrets" = herculesSecret;

  services.hercules-ci-agent = {
    enable = true;
    settings = {
      binaryCachesPath = secrets."binary-caches.json".path;
      clusterJoinTokenPath = secrets."cluster-join-token.key".path;
      secretsJsonPath = secrets."hercules-secrets".path;
    };
  };

  # Fix OOM events: https://github.com/hercules-ci/hercules-ci-agent/commit/b670e0601cd6bb1264f55f7b61bf4fbdcdc34bf1
  systemd.services.hercules-ci-agent.serviceConfig = {
    LimitSTACK = 256 * 1024 * 1024;
    OOMPolicy = "continue";
  };
}
