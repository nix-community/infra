{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:

let
  asGB = size: toString (size * 1024 * 1024 * 1024);
in
{
  nixpkgs.overlays =
    lib.optionals (config.networking.hostName == "build02" || config.networking.hostName == "build03")
      [
        (final: prev: {
          nix-eval-jobs = prev.nix-eval-jobs.overrideAttrs (
            _: p: {
              version = "2.35.2-unstable-2026-09-01";
              src = final.fetchFromGitHub {
                owner = "NixOS";
                repo = "nix-eval-jobs";
                rev = "55e658518ae417cf26f36643fcfdebe5c5db17aa";
                hash = "sha256-4z5GnNd9cbkKChaovYghlxuh1k5rYlxNT7wpZeR1oU0=";
              };
              buildInputs = (p.buildInputs or [ ]) ++ [ final.mimalloc ];
            }
          );
        })
      ];

  nix = {
    settings.trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ]
    ++ lib.optionals (config.networking.hostName != "build03") [
      "temp-cache.nix-community.org-1:RSXIfGjilfBsilDvj03/VnL/9qAxacBnb1YQvSdCoDc="
    ];

    settings.substituters = [
      "https://nix-community.cachix.org"
    ]
    ++ lib.optionals (config.networking.hostName != "build03") [
      "https://temp-cache.nix-community.org"
    ];

    # Hard-link duplicated files
    settings.auto-optimise-store = true;
    optimise.automatic = false;

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
