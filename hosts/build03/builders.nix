{ config, inputs, ... }:
{
  age.secrets.id_buildfarm = {
    file = "${inputs.self}/secrets/id_buildfarm.age";
  };

  nix.distributedBuilds = true;
  nix.buildMachines = [
    {
      hostName = "build04.nix-community.org";
      maxJobs = 80;
      protocol = "ssh-ng";
      sshKey = config.age.secrets.id_buildfarm.path;
      sshUser = "nix";
      systems = [ "aarch64-linux" ];
      supportedFeatures =
        inputs.self.outputs.nixosConfigurations.build04.config.nix.settings.system-features;
    }
    {
      hostName = "darwin02.nix-community.org";
      maxJobs = 8;
      protocol = "ssh-ng";
      sshKey = config.age.secrets.id_buildfarm.path;
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
