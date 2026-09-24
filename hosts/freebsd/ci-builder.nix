{ config, inputs, ... }:
{
  nixpkgs.overlays = [
    (final: prev: {
      hydraPackages = import ../../dev/hydra-packages.nix {
        inherit final inputs;
      };
    })
  ];

  services.hydra-queue-builder-dev = {
    enable = true;
    authorizationFile = "/mnt/secrets/freebsd-queue-builder-token";
    queueRunnerAddr = "https://queue-runner.hydra.nix-community.org";
  };

  init.services.hydra-queue-builder-dev = {
    requiredFiles = [ config.services.hydra-queue-builder-dev.authorizationFile ];
  };

  virtualisation.vmVariant.virtualisation.sharedDirectories.secrets = {
    source = "/var/lib/vm-builder/secrets";
    target = "/mnt/secrets";
    type = "9p";
    readOnly = true;
  };
}
