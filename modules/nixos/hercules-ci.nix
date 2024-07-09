{ config, inputs, ... }:
{
  age.secrets.hercules-binary-caches = {
    file = "${toString inputs.self}/secrets/hercules-binary-caches.age";
    owner = "hercules-ci-agent";
  };

  age.secrets.hercules-cluster-join-token = {
    file = "${toString inputs.self}/secrets/hercules-cluster-join-token.age";
    owner = "hercules-ci-agent";
  };

  age.secrets.hercules-secrets = {
    file = "${toString inputs.self}/secrets/hercules-secrets.age";
    owner = "hercules-ci-agent";
  };

  services.hercules-ci-agent = {
    enable = true;
    settings = {
      binaryCachesPath = config.age.secrets.hercules-binary-caches.path;
      clusterJoinTokenPath = config.age.secrets.hercules-cluster-join-token.path;
      # secrets file is needed for effects
      secretsJsonPath = config.age.secrets.hercules-secrets.path;
    };
  };
}
