{ config, ... }:
{
  nix.distributedBuilds = true;
  nix.buildMachines = [
    {
      hostName = "aarch64.nixos.community";
      maxJobs = 64;
      sshKey = config.sops.secrets.aarch64_nixos_community.path;
      sshUser = "nixcommunity";
      system = "aarch64-linux";
      supportedFeatures = [
        "big-parallel"
        "kvm"
        "nixos-test"
      ];
    }
  ];
  sops.secrets.aarch64_nixos_community = { };
}
