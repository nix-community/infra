{
  config,
  inputs,
  ...
}:
{
  imports = [
    ../shared/ci-builder.nix
    "${inputs.self}/modules/queue-runner/hydra-queue-builder-v2.nix"
  ];

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
