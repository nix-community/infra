{ config, inputs, ... }:
let
  secret = {
    owner = "hercules-ci-agent";
    sopsFile = "${inputs.self}/modules/secrets/hercules-ci.yaml";
  };
in
{
  sops.secrets.hercules-binary-caches = secret;

  sops.secrets.hercules-cluster-join-token = secret;

  sops.secrets.hercules-secrets = secret;

  services.hercules-ci-agent = {
    enable = true;
    settings = {
      binaryCachesPath = config.sops.secrets.hercules-binary-caches.path;
      clusterJoinTokenPath = config.sops.secrets.hercules-cluster-join-token.path;
      # secrets file is needed for effects
      secretsJsonPath = config.sops.secrets.hercules-secrets.path;
    };
  };
}
