{ config, ... }:
{
  nix.distributedBuilds = true;
  nix.buildMachines = [
    {
      hostName = "aarch64.nixos.community";
      maxJobs = 4;
      sshKey = config.sops.secrets.id_buildfarm.path;
      sshUser = "ssh-ng://nix";
      system = "aarch64-linux";
      supportedFeatures = [
        "big-parallel"
        "kvm"
        "nixos-test"
      ];
    }
  ];
  sops.secrets.id_buildfarm = {};
}
