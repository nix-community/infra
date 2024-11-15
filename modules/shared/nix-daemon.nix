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
    ];

    settings.substituters = [ "https://nix-community.cachix.org" ];

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

    # match buildbot timeouts
    # https://github.com/nix-community/buildbot-nix/blob/85c0b246cc96cc244e4d9889a97c4991c4593dc3/buildbot_nix/__init__.py#L1008
    settings.max-silent-time = toString (60 * 20);
    settings.timeout = toString (60 * 60 * 3);
  };
}
