{ config, inputs, ... }:
let
  inherit (inputs.self) darwinConfigurations nixosConfigurations;
in
{
  sops.secrets.id_buildfarm = { };

  nix.distributedBuilds = true;
  nix.buildMachines =
    map
      (x: {
        hostName = "${x.config.networking.hostName}.nix-community.org";
        maxJobs = x.config.nix.settings.max-jobs;
        protocol = "ssh-ng";
        sshKey = config.sops.secrets.id_buildfarm.path;
        sshUser = "nix";
        systems = [
          x.config.nixpkgs.hostPlatform.system
        ] ++ (x.config.nix.settings.extra-platforms or [ ]);
        supportedFeatures = x.config.nix.settings.system-features;
      })
      [
        darwinConfigurations.darwin02
        nixosConfigurations.build04
      ];
}
