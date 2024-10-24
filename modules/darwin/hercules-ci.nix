{ config, inputs, ... }:
{
  age.secrets.hercules-binary-caches = {
    file = "${inputs.self}/secrets/hercules-binary-caches.age";
    mode = "600";
    owner = "_hercules-ci-agent";
    group = "_hercules-ci-agent";
  };

  age.secrets.hercules-cluster-join-token = {
    file = "${inputs.self}/secrets/hercules-cluster-join-token.age";
    mode = "600";
    owner = "_hercules-ci-agent";
    group = "_hercules-ci-agent";
  };

  services.hercules-ci-agent = {
    enable = true;
    settings = {
      binaryCachesPath = config.age.secrets.hercules-binary-caches.path;
      clusterJoinTokenPath = config.age.secrets.hercules-cluster-join-token.path;
    };
  };
}
