{
  config,
  inputs,
  pkgs,
  ...
}:

let
  asGB = size: toString (size * 1024 * 1024 * 1024);
in
{
  nix = {
    settings.trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "temp-cache.nix-community.org-1:RSXIfGjilfBsilDvj03/VnL/9qAxacBnb1YQvSdCoDc="
    ];

    settings.substituters = [
      "https://nix-community.cachix.org"
      "https://temp-cache.nix-community.org"
    ];

    # auto-free the /nix/store
    settings.min-free = asGB 1;
    settings.max-free = asGB 50;

    channel.enable = false;
    # disable global registry
    settings.flake-registry = "";
    # set system registry
    registry = {
      nixpkgs.to = {
        type = "path";
        path = inputs.nixpkgs;
      };
      self.to = {
        type = "path";
        path = inputs.self;
      };
    };
    # explicitly set nix-path, NIX_PATH to nixpkgs from system registry
    settings.nix-path = [ "nixpkgs=flake:nixpkgs" ];
    nixPath = config.nix.settings.nix-path;

    gc.automatic = pkgs.lib.mkDefault true;
    gc.options = pkgs.lib.mkDefault "--delete-older-than 14d";
  };
}
