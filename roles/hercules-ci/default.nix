{ config, lib, ... }:
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

  services.hercules-ci-agent = {
    enable = true;
    settings = {
      binaryCachesPath = secrets."binary-caches.json".path;
      clusterJoinTokenPath = secrets."cluster-join-token.key".path;
      # workaround for "could not retrieve derivation"
      # https://github.com/hercules-ci/hercules-ci-agent/issues/314
      nixUserIsTrusted = lib.mkForce false;
    };
  };
}
