{ pkgs, ... }:
{
  imports = [
    ./flake-inputs.nix
    ./reboot.nix
    ./telegraf.nix
    ../../shared/nix-daemon.nix
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

  # `time.timeZone` works but displays error message during activation
  # https://github.com/LnL7/nix-darwin/issues/359
  # https://github.com/LnL7/nix-darwin/blob/16c07487ac9bc59f58b121d13160c67befa3342e/modules/time/default.nix#L14
  system.activationScripts.postActivation.text = ''
    systemsetup -settimezone "GMT" >/dev/null 2>&1
  '';
}
