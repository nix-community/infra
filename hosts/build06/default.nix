{ inputs, ... }:
{
  imports = [
    # currently only works with new hydra-queue-builder, not hercules or buildbot (nix.distributedBuilds)
    ./nvidia.nix
    inputs.self.nixosModules.cgroups
    inputs.self.nixosModules.ci-builder
    inputs.self.nixosModules.disko-zfs
    inputs.srvos.nixosModules.hardware-hetzner-online-intel
  ];

  nixCommunity.hydra-queue-builder-v2 = {
    maxJobs = 2;
    mandatoryFeatures = [ "cuda" ];
  };

  nix.settings.max-jobs = 14;

  systemd.network.networks."10-uplink".networkConfig.Address = "1.2.3.4";

  system.stateVersion = "24.11";
}
