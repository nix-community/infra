{
  config,
  inputs,
  lib,
  ...
}:
{
  imports = [
    ../shared/ci-builder.nix
    "${inputs.nixos-infra}/non-critical-infra/modules/hydra-queue-builder-v2.nix"
  ];

  sops.secrets.queue-runner-client-key.owner = "hydra-queue-builder";

  nix.settings.allowed-users = lib.mkForce [
    "*"
  ];

  nix.settings.extra-allowed-users = [
    "hydra-queue-builder"
  ];

  services.hydra-queue-builder-v2 = {
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
