{ config, inputs, ... }:
let
  inherit (inputs.self) darwinConfigurations nixosConfigurations;

  machines = [
    darwinConfigurations.darwin02
    nixosConfigurations.build04
  ];
in
{
  sops.secrets.id_buildfarm = { };

  nix.distributedBuilds = true;
  nix.buildMachines = builtins.concatMap (
    x:
    let
      common = {
        hostName = "${x.config.networking.hostName}.nix-community.org";
        protocol = "ssh-ng";
        sshKey = config.sops.secrets.id_buildfarm.path;
        sshUser = "nix";
      };
    in
    [
      (
        common
        // {
          maxJobs = x.config.nix.settings.max-jobs;
          systems = [
            x.pkgs.stdenv.hostPlatform.system
          ]
          ++ (x.config.nix.settings.extra-platforms or [ ]);
          supportedFeatures = x.config.nix.settings.system-features;
        }
      )
    ]
    ++ map (
      m:
      common
      // {
        inherit (m)
          maxJobs
          supportedFeatures
          systems
          ;
      }
    ) (x.config.nix.buildMachines or [ ])
  ) machines;

  services.telegraf.extraConfig.inputs.net_response = map (x: {
    protocol = "tcp";
    address = "${x.config.networking.hostName}.nix-community.org:22";
    send = "SSH-2.0-Telegraf";
    expect = "SSH-2.0";
    tags.host = "${x.config.networking.hostName}.nix-community.org";
    tags.org = "nix-community";
    timeout = "10s";
  }) machines;
}
