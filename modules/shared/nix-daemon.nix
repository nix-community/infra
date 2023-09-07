{ pkgs, ... }:

let
  asGB = size: toString (size * 1024 * 1024 * 1024);
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
    settings.min-free = asGB 30;
    settings.max-free = asGB 50;

    # useful for ad-hoc nix-shell's for debugging
    # use mkForce to avoid search path warnings with nix-darwin
    nixPath = pkgs.lib.mkForce [ "nixpkgs=${pkgs.path}" ];

    gc.automatic = true;
    gc.options = "--delete-older-than 14d";
  };
}
