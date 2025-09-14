{ config, ... }:
{
  nix.settings.cores = config.nix.settings.max-jobs / 4;

  # match buildbot timeouts
  # https://github.com/nix-community/buildbot-nix/blob/85c0b246cc96cc244e4d9889a97c4991c4593dc3/buildbot_nix/__init__.py#L1008

  # causes problems with cgroups: https://github.com/nix-community/infra/issues/1459#issuecomment-2507146996
  nix.settings.max-silent-time = toString (60 * 20 * 3); # 3x buildbot

  nix.settings.timeout = toString (60 * 60 * 3);

  sops.secrets.queue-runner-client-key.owner = "hydra-queue-builder";

  nixCommunity.hydra-queue-builder-v2 = {
    enable = true;
    queueRunnerAddr = "https://queue-runner.hydra.nix-community.org";
    mtls = {
      serverRootCaCertPath = "${../../hosts/build03/ca.crt}";
      clientCertPath = "${../../hosts/${config.networking.hostName}/client.crt}";
      clientKeyPath = config.sops.secrets.queue-runner-client-key.path;
      domainName = "queue-runner.hydra.nix-community.org";
    };
  };
}
