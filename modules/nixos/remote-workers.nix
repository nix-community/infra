{ config, ... }:
{
  sops.secrets.id_buildfarm = { };

  nix.distributedBuilds = true;
  nix.buildMachines = [
    # these machines are used by hydra which doesn't support ssh-ng
    {
      hostName = "build04.nix-community.org";
      maxJobs = 4;
      protocol = "ssh";
      sshKey = config.sops.secrets.id_buildfarm.path;
      sshUser = "nix";
      system = "aarch64-linux";
      supportedFeatures = [ "big-parallel" ];
    }
    {
      hostName = "darwin02.nix-community.org";
      maxJobs = 8;
      protocol = "ssh";
      sshKey = config.sops.secrets.id_buildfarm.path;
      sshUser = "nix";
      systems = [ "aarch64-darwin" "x86_64-darwin" ];
      supportedFeatures = [ "big-parallel" ];
    }
  ];
}
