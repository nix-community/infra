{ pkgs, ... }:

let
  asGB = size: toString (size * 1024 * 1024);
in
{
  nix = {
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

  users.groups.trusted = { };
}
