{ inputs, ... }:
{
  # builder ssh key is installed manually from ./secrets.yaml

  nix.distributedBuilds = true;
  nix.buildMachines = [
    {
      hostName = "darwin03.nix-community.org";
      maxJobs = 8;
      protocol = "ssh-ng";
      sshKey = "/etc/nix/darwin-community-builder.key";
      sshUser = "nix";
      systems = [ "aarch64-darwin" "x86_64-darwin" ];
      supportedFeatures = inputs.self.outputs.darwinConfigurations.darwin03.config.nix.settings.system-features;
    }
  ];
}
