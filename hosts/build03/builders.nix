{
  config,
  inputs,
  lib,
  ...
}:
let
  inherit (inputs.self) darwinConfigurations nixosConfigurations;
in
{
  sops.secrets.id_buildfarm = { };

  nix.distributedBuilds = true;
  nix.buildMachines =
    map
      (
        x:
        let
          mandatoryFeatures = x.config.nixCommunity.remote-builder.mandatoryFeatures;
          systemFeatures = x.config.nix.settings.system-features;
          # dedupe /etc/nix/machines
          supportedFeatures = lib.lists.subtractLists mandatoryFeatures systemFeatures;
        in
        {
          hostName = "${x.config.networking.hostName}.nix-community.org";
          maxJobs = x.config.nixCommunity.remote-builder.maxJobs;
          protocol = "ssh-ng";
          sshKey = config.sops.secrets.id_buildfarm.path;
          sshUser = "nix";
          systems = [
            x.config.nixpkgs.hostPlatform.system
          ] ++ (x.config.nix.settings.extra-platforms or [ ]);
          inherit mandatoryFeatures supportedFeatures;
        }
      )
      [
        darwinConfigurations.darwin02
        nixosConfigurations.build04
      ];
}
