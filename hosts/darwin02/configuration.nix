{ inputs, pkgs, ... }:
let
  asGB = size: toString (size * 1024 * 1024);
in
{
  # hercules secrets are installed manually from ./secrets.yaml
  # https://docs.hercules-ci.com/hercules-ci/getting-started/deploy/nix-darwin
  services.hercules-ci-agent = {
    enable = true;
    # https://github.com/hercules-ci/hercules-ci-agent/pull/507
    package = inputs.hcia.legacyPackages.${pkgs.system}.hercules-ci-agent;
  };

  imports = [ ./builder.nix ];

  services.nix-daemon.enable = true;

  nix.settings.sandbox = "relaxed";
  nix.settings.extra-platforms = [ "x86_64-darwin" ];

  programs.zsh.enable = true;

  networking.hostName = "darwin02";

  system.stateVersion = 4;

  documentation.enable = false;

  programs.info.enable = false;

  # TODO: refactor this to share /users with nixos
  # keys are copied, not symlinked
  users.users.m1.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOG/9rsFqC2tg+W5YZxthW5xhUJEfZ8ShqkRtVe+A6+u" # hercules-ssh-deploy
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKbBp2dH2X3dcU1zh+xW3ZsdYROKpJd3n13ssOP092qE" # mic92
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOuiDoBOxgyer8vGcfAIbE6TC4n4jo8lhG9l01iJ0bZz" # zimbatm
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFbCYwWByGE46XHH4Q0vZgQ5sOUgbH50M8KO2xhBC4m/" # zowoq
  ];

  nix.settings.trusted-users = [
    "@admin"
  ];

  nix.settings.builders-use-substitutes = true;

  nix.settings.substituters = [ "https://nix-community.cachix.org/" ];
  nix.settings.trusted-public-keys = [
    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nix.settings.auto-optimise-store = true;

  nix.settings.min-free = asGB 10;
  nix.settings.max-free = asGB 200;

  nix.nixPath = [ "nixpkgs=${pkgs.path}" ];

  nix.gc.automatic = true;
  nix.gc.options = "--delete-older-than 14d";
}
