{ pkgs, ... }:
let
  asGB = size: toString (size * 1024 * 1024);
in
{
  imports = [
    ./flake-inputs.nix
    ./telegraf.nix
  ];

  # use the same version as srvos
  # https://github.com/numtide/srvos/blob/main/nixos/common/nix.nix#L4
  nix.package = pkgs.nixVersions.nix_2_16;

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

  # avoid search path warnings
  nix.nixPath = pkgs.lib.mkForce [ "nixpkgs=${pkgs.path}" ];

  nix.gc.automatic = true;
  nix.gc.options = "--delete-older-than 14d";

  environment.systemPackages = with pkgs; [
    htop
  ];

  # srvos
  services.openssh.authorizedKeysFiles = pkgs.lib.mkForce [ "/etc/ssh/authorized_keys.d/%u" ];

  # srvos
  environment.etc."ssh/sshd_config.d/darwin.conf".text = ''
    KbdInteractiveAuthentication no
    PasswordAuthentication no
  '';

  # works but displays error message during activation
  # https://github.com/LnL7/nix-darwin/issues/359
  # sudo systemsetup -settimezone 'GMT'
  #time.timeZone = "GMT";
}
