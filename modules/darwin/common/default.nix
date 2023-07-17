{ pkgs, ... }:
let
  asGB = size: toString (size * 1024 * 1024);
in
{
  imports = [
    ./telegraf.nix
  ];

  services.nix-daemon.enable = true;

  programs.zsh.enable = true;

  documentation.enable = false;

  programs.info.enable = false;

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

  environment.systemPackages = with pkgs; [
    htop
  ];

  # works but displays error message during activation
  # https://github.com/LnL7/nix-darwin/issues/359
  # sudo systemsetup -settimezone 'GMT'
  #time.timeZone = "GMT";
}
