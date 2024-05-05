{ config, pkgs, ... }:
let
  securityWrapper = pkgs.writeScriptBin "security" ''
    exec /usr/bin/security "$@"
  '';
in
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

  # hercules-ci-agent: security: createProcess: posix_spawnp: does not exist
  # https://github.com/LnL7/nix-darwin/blob/36524adc31566655f2f4d55ad6b875fb5c1a4083/modules/services/hercules-ci-agent/default.nix#L28
  launchd.daemons.hercules-ci-agent.path = pkgs.lib.mkForce [ config.nix.package securityWrapper ];
}
