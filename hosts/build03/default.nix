{ inputs, ... }:
{
  imports = [
    ./builders.nix
    ./postgresql.nix
    inputs.self.nixosModules.buildbot
    inputs.self.nixosModules.cgroups
    inputs.self.nixosModules.ci-builder
    inputs.self.nixosModules.disko-zfs
    inputs.self.nixosModules.github-org-backup
    inputs.self.nixosModules.hercules-ci
    inputs.self.nixosModules.hydra
    inputs.self.nixosModules.nginx
    inputs.self.nixosModules.nur-update
    inputs.self.nixosModules.watch-store
    inputs.srvos.nixosModules.hardware-hetzner-online-amd
  ];

  systemd.targets.network-online.wantedBy = [ "multi-user.target" ];

  nix.settings.max-jobs = 96;

  nixpkgs.hostPlatform.gcc.arch = "znver4";

  systemd.network.networks."10-uplink".networkConfig.Address = "2a01:4f8:2190:2698::2";

  system.stateVersion = "23.11";
}
