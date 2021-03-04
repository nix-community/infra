{ config, lib, pkgs, ... }:

let
  asGB = size: toString (size * 1024 * 1024);
in
{
  nix = {
    binaryCachePublicKeys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];

    binaryCaches = [
      "https://nix-community.cachix.org"
    ];

    extraOptions = ''
      # auto-free the /nix/store
      min-free = ${asGB 10}
      max-free = ${asGB 200}

      # avoid copying unecessary stuff over SSH
      builders-use-substitutes = true

      # allow flakes
      experimental-features = nix-command flakes
    '';
    # Hard-link duplicated files
    autoOptimiseStore = true;

    # Add support for flakes
    package = pkgs.nixUnstable;

    gc.automatic = true;
    gc.options = "--delete-older-than 30d";
  };
}
