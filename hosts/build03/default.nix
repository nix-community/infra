{ inputs, ... }:
{
  imports = [
    ./builders.nix
    ./cache.nix
    ./landscape.nix
    ./postgresql.nix
    ./queue-runner.nix
    inputs.self.nixosModules.buildbot
    inputs.self.nixosModules.ci-builder
    inputs.self.nixosModules.disko-zfs
    inputs.self.nixosModules.github-org-backup
    inputs.self.nixosModules.hercules-ci
    inputs.self.nixosModules.hydra
    inputs.self.nixosModules.nginx
    inputs.self.nixosModules.nur-update
    inputs.self.nixosModules.quadlet
    inputs.self.nixosModules.rfc39
    inputs.self.nixosModules.watch-store
    inputs.srvos.nixosModules.hardware-hetzner-online-amd
  ];

  # hercules-ci is disabled on darwin02
  # https://github.com/NixOS/nixpkgs/issues/461651#issuecomment-3536203369
  services.hercules-ci-agent.settings.remotePlatformsWithSameFeatures = [
    "aarch64-darwin"
    "x86_64-darwin"
  ];

  systemd.settings.Manager.RuntimeWatchdogSec = "30s";

  nix.settings.max-jobs = 96;

  systemd.network.networks."10-uplink".networkConfig.Address = "2a01:4f8:2190:2698::2";

  system.stateVersion = "23.11";
}
