{ config, ... }:
{
  nix.distributedBuilds = true;
  nix.buildMachines = [
    {
      hostName = "build05.nix-community.org";
      maxJobs = 16;
      protocol = "ssh"; # this machine is used by hydra which doesn't support ssh-ng
      sshKey = config.sops.secrets.id_buildfarm.path;
      sshUser = "nix";
      system = "aarch64-linux";
      supportedFeatures = [ "big-parallel" ];
    }
  ];
  sops.secrets.id_buildfarm = { };
}
