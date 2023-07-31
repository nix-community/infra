{ pkgs, ... }:
{
  imports = [
    ./flake-inputs.nix
    ./reboot.nix
    ./telegraf.nix
    ../../shared/nix-daemon.nix
  ];

  # TODO: refactor this to share /users with nixos
  # if user is removed the keys need to be removed manually from /etc/ssh/authorized_keys.d
  users.users = {
    hetzner.openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOG/9rsFqC2tg+W5YZxthW5xhUJEfZ8ShqkRtVe+A6+u" # hercules-ssh-deploy
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKbBp2dH2X3dcU1zh+xW3ZsdYROKpJd3n13ssOP092qE" # mic92
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOuiDoBOxgyer8vGcfAIbE6TC4n4jo8lhG9l01iJ0bZz" # zimbatm
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFbCYwWByGE46XHH4Q0vZgQ5sOUgbH50M8KO2xhBC4m/" # zowoq
    ];
  };

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
