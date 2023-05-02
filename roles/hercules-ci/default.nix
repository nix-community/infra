{ config, inputs, pkgs, ... }:
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
    # https://github.com/hercules-ci/hercules-ci-agent/issues/514#issuecomment-1530341970
    package = inputs.hercules-pin.legacyPackages.${pkgs.system}.hercules-ci-agent;
  };
}
