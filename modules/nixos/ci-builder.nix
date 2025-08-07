{
  config,
  inputs,
  pkgs,
  ...
}:
{
  options.services.hydra-dev.package.nix = pkgs.lib.mkPackageOption config.nix "package" { };

  imports = [
    ../shared/ci-builder.nix
    "${inputs.nixos-infra}/non-critical-infra/modules/hydra-queue-builder-v2.nix"
  ];

  config = {
    sops.secrets.queue-runner-client-key.owner = "hydra-queue-builder";

    services.hydra-queue-builder-v2 = {
      enable = true;
      queueRunnerAddr = "https://queue-runner.hydra.nix-community.org";
      mtls = {
        serverRootCaCertPath = "${inputs.self}/hosts/build03/ca.crt";
        clientCertPath = "${inputs.self}/hosts/${config.networking.hostName}/client.crt";
        clientKeyPath = config.sops.secrets.queue-runner-client-key.path;
        domainName = "queue-runner.hydra.nix-community.org";
      };
    };
  };
}
