{ config, ... }:
{
  age.secrets.binary-caches = {
    file = ../../../secrets/binary-caches.age;
    mode = "600";
    owner = "_hercules-ci-agent";
    group = "_hercules-ci-agent";
  };

  age.secrets.cluster-join-token = {
    file = ../../../secrets/cluster-join-token.age;
    mode = "600";
    owner = "_hercules-ci-agent";
    group = "_hercules-ci-agent";
  };

  services.hercules-ci-agent.enable = true;

  services.hercules-ci-agent.settings = {
    binaryCachesPath = config.age.secrets.binary-caches.path;
    clusterJoinTokenPath = config.age.secrets.cluster-join-token.path;
  };
}
