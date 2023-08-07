{ config, ... }:
{
  nix.distributedBuilds = true;
  nix.buildMachines = [
    {
      hostName = "build01.nix-community.org";
      maxJobs = 16;
      protocol = "ssh"; # this machine is used by hydra which doesn't support ssh-ng
      sshKey = config.sops.secrets.id_buildfarm.path;
      sshUser = "nix";
      system = "x86_64-linux";
      supportedFeatures = [ "big-parallel" "kvm" "nixos-tests" ];
    }
  ];
  sops.secrets.id_buildfarm = { };
}
