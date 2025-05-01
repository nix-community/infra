{
  config,
  inputs,
  lib,
  ...
}:
let
  inherit (inputs.self) darwinConfigurations nixosConfigurations;

  machines = [
    darwinConfigurations.darwin02
    nixosConfigurations.build04
    nixosConfigurations.build06
  ];
in
{
  sops.secrets.id_buildfarm = { };

  nix.distributedBuilds = true;
  nix.buildMachines = map (
    x:
    let
      isCuda = (lib.elem "cuda" x.config.nix.settings.system-features);
    in
    {
      hostName = "${x.config.networking.hostName}.nix-community.org";
      maxJobs = if isCuda then 2 else x.config.nix.settings.max-jobs;
      protocol = "ssh-ng";
      sshKey = config.sops.secrets.id_buildfarm.path;
      sshUser = "nix";
      systems = [
        x.pkgs.stdenv.hostPlatform.system
      ] ++ (x.config.nix.settings.extra-platforms or [ ]);
      supportedFeatures = x.config.nix.settings.system-features;
    }
    // lib.optionalAttrs isCuda {
      mandatoryFeatures = [ "cuda" ];
    }
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
