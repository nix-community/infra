{ config, ... }:
{
  nix.distributedBuilds = true;
  nix.buildMachines = [
    {
      hostName = "build04.nix-community.org";
      maxJobs = 4;
      protocol = "ssh"; # this machine is used by hydra which doesn't support ssh-ng
      sshKey = config.sops.secrets.id_buildfarm.path;
      sshUser = "nix";
      system = "aarch64-linux";
      supportedFeatures = [ "big-parallel" ]; # sync with build04/configuration.nix
    }
  ];
  sops.secrets.id_buildfarm = { };
}
