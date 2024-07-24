{ config, inputs, ... }:
{
  sops.secrets.id_buildfarm = { };

  nix.distributedBuilds = true;
  nix.buildMachines = [
    {
      hostName = "build04.nix-community.org";
      maxJobs = 80;
      protocol = "ssh-ng";
      sshKey = config.sops.secrets.id_buildfarm.path;
      sshUser = "nix";
      systems = [ "aarch64-linux" ];
      supportedFeatures =
        inputs.self.outputs.nixosConfigurations.build04.config.nix.settings.system-features;
    }
    {
      hostName = "darwin02.nix-community.org";
      maxJobs = 8;
      protocol = "ssh-ng";
      sshKey = config.sops.secrets.id_buildfarm.path;
      sshUser = "nix";
      systems = [
        "aarch64-darwin"
        "x86_64-darwin"
      ];
      supportedFeatures =
        inputs.self.outputs.darwinConfigurations.darwin02.config.nix.settings.system-features;
    }
  ];
}
