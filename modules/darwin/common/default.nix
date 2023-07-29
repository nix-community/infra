{ pkgs, ... }:
{
  imports = [
    ./telegraf.nix
    ../../shared/nix-daemon.nix
  ];

  services.nix-daemon.enable = true;

  programs.zsh.enable = true;

  documentation.enable = false;

  programs.info.enable = false;

  nix.settings.trusted-users = [
    "@admin"
  ];

  # srvos
  nix.settings.builders-use-substitutes = true;

  # srvos
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  environment.systemPackages = with pkgs; [
    htop
  ];

  # works but displays error message during activation
  # https://github.com/LnL7/nix-darwin/issues/359
  # sudo systemsetup -settimezone 'GMT'
  #time.timeZone = "GMT";
}
