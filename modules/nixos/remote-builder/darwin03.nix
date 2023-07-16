{ config, ... }:
{
  nix.distributedBuilds = true;
  nix.buildMachines = [
    {
      hostName = "darwin03.nix-community.org";
      maxJobs = 8;
      protocol = "ssh"; # this machine is used by hydra which doesn't support ssh-ng
      sshKey = config.sops.secrets.id_buildfarm.path;
      sshUser = "nix";
      systems = [ "aarch64-darwin" "x86_64-darwin" ];
      supportedFeatures = [ "big-parallel" ];
    }
  ];
  sops.secrets.id_buildfarm = { };
}
