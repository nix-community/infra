{
  config,
  inputs,
  pkgs,
  ...
}:
{
  assertions = [
    {
      assertion = config.nix.package.version == pkgs.hydraPackages.hydra.nix.version;
      message = "keep nix versions in sync";
    }
  ];

  nix.settings.cores = config.nix.settings.max-jobs / 4;

  # match nixbot timeouts
  # https://github.com/Mic92/nixbot/blob/6764a0ef1c704b6db339f19d81cb5642a2508dff/nixosModules/nixbot.nix#L264

  # causes problems with cgroups: https://github.com/nix-community/infra/issues/1459#issuecomment-2507146996
  nix.settings.max-silent-time = toString (60 * 20 * 3); # 3x nixbot

  nix.settings.timeout = toString (60 * 60 * 3);

  nix.package = pkgs.nixVersions.nix_2_35;

  sops.secrets.hydra-queue-builder = {
    key = "hydra-queue-builder-token-${config.networking.hostName}";
    owner = "hydra-queue-builder";
    sopsFile = "${inputs.self}/modules/secrets/hydra-queue-builder.yaml";
  };

  services.hydra-queue-builder-dev = {
    enable = true;
    authorizationFile = config.sops.secrets.hydra-queue-builder.path;
    queueRunnerAddr = "https://queue-runner.hydra.nix-community.org";
    settings = {
      maxJobs = 4;
    };
  };
}
