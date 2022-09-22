{ config, ... }:
{
  nix.distributedBuilds = true;
  nix.buildMachines = [
    {
      hostName = "build04.nix-community.org";
      maxJobs = 4;
      sshKey = config.sops.secrets.id_buildfarm.path;
      sshUser = "nix";
      protocol = "ssh-ng";
      system = "aarch64-linux";
      supportedFeatures = [
        "big-parallel"
        "kvm"
        "nixos-test"
      ];
    }
  ];
  sops.secrets.id_buildfarm = { };
}
