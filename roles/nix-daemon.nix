{ config, lib, pkgs, inputs, ... }:

let
  asGB = size: toString (size * 1024 * 1024);
in
{
  nix = {
    settings.trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];

    settings.substituters = [
      "https://nix-community.cachix.org"
    ];

    # Hard-link duplicated files
    settings.auto-optimise-store = true;

    # auto-free the /nix/store
    settings.min-free = asGB 10;
    settings.max-free = asGB 200;

    # users in trusted group are trusted by the nix-daemon
    settings.trusted-users = [ "@trusted" ];

    # useful for ad-hoc nix-shell's for debugging
    nixPath = [ "nixpkgs=${pkgs.path}" ];

    gc.automatic = true;
    gc.options = "--delete-older-than 14d";
  };

  # Sometimes it fails if a store path is still in use.
  # This should fix intermediate issues.
  systemd.services.nix-gc.serviceConfig = {
    Restart = "on-failure";
  };

  # inputs == flake inputs in configurations.nix
  environment.etc = let
    inputsWithDate = lib.filterAttrs (_: input: input ? lastModified) inputs;
    flakeAttrs = input: (lib.mapAttrsToList (n: v: ''${n}="${v}"'')
      (lib.filterAttrs (n: v: (builtins.typeOf v) == "string") input));
    lastModified = name: input: ''
      flake_input_last_modified{input="${name}",${lib.concatStringsSep "," (flakeAttrs input)}} ${toString input.lastModified}
    '';
  in {
    "flake-inputs.prom" = {
      mode = "0555";
      text = ''
        # HELP flake_registry_last_modified Last modification date of flake input in unixtime
        # TYPE flake_input_last_modified gauge
        ${lib.concatStringsSep "\n" (lib.mapAttrsToList lastModified inputsWithDate)}
      '';
    };
  };

  services.telegraf.extraConfig.inputs.file = [
    {
      data_format = "prometheus";
      files = [ "/etc/flake-inputs.prom" ];
    }
  ];

  users.groups.trusted = { };
}
