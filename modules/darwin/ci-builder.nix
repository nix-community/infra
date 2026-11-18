{
  config,
  inputs,
  lib,
  ...
}:
let
  instances = {
    standard = {
      buildCores = 2;
      maxJobs = 10;
    };
    big-parallel = {
      buildCores = 5;
      maxJobs = 1;
      mandatoryFeatures = [ "big-parallel" ];
    };
  };
in
{
  imports = [
    ../shared/ci-builder.nix
    (import "${inputs.hydra}/darwin-modules/builder-module.nix")
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

  users = {
    users.hydra-queue-builder.uid = 6535;
    groups.hydra.gid = 6535;
  };
}
