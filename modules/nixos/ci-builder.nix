{
  config,
  inputs,
  lib,
  ...
}:
let
  instances = {
    standard = {
      buildCores = 4;
      maxJobs = 16;
    };
    big-parallel = {
      buildCores = 30;
      maxJobs = 1;
      mandatoryFeatures = [ "big-parallel" ];
    };
    nixos-test = {
      buildCores = 4;
      maxJobs = 4;
      mandatoryFeatures = [ "nixos-test" ];
    };
  };
in
{
  disabledModules = [
    "services/continuous-integration/hydra/builder.nix"
    "services/continuous-integration/hydra/default.nix"
  ];

  imports = [
    ../shared/ci-builder.nix
    (import "${inputs.hydra}/nixos-modules/builder-module.nix")
  ];

  services.hydra-queue-builder-dev.instances = lib.mapAttrs (name: settings: {
    inherit settings;
    queueRunnerAddr = "https://queue-runner.hydra.nix-community.org";
    authorizationFile = config.sops.secrets."hydra-queue-builder-${name}".path;
  }) instances;

  sops.secrets = lib.mapAttrs' (name: _: {
    name = "hydra-queue-builder-${name}";
    value = {
      key = "hydra-queue-builder-token-${config.networking.hostName}-${name}";
      owner = "hydra-queue-builder";
      sopsFile = "${inputs.self}/modules/secrets/hydra-queue-builder.yaml";
    };
  }) instances;
}
