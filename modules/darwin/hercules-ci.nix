{ config, inputs, ... }:

let
  secret = {
    mode = "600";
    owner = "_hercules-ci-agent";
    group = "_hercules-ci-agent";
    sopsFile = "${inputs.self}/modules/secrets/hercules-ci.yaml";
  };
in
{
  sops.secrets.hercules-binary-caches = secret;

  sops.secrets.hercules-cluster-join-token = secret;

  services.hercules-ci-agent = {
    enable = true;
    settings = {
      binaryCachesPath = config.sops.secrets.hercules-binary-caches.path;
      clusterJoinTokenPath = config.sops.secrets.hercules-cluster-join-token.path;
      # secretsJsonPath / hercules-secrets isn't needed on darwin
    };
  };
}
