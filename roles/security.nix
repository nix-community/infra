{ config, pkgs, lib, ... }:

{
  # Make sure that the firewall is enabled, even if it's the default.
  networking.firewall.enable = true;

  # Allow password-less sudo for wheel users
  security.sudo.enable = true;
  security.sudo.wheelNeedsPassword = false;

  # Dont let users create their own authorized keys files
  services.openssh.authorizedKeysFiles = lib.mkForce [
    "/etc/ssh/authorized_keys.d/%u"
  ];

  services.openssh.challengeResponseAuthentication = false;
  services.openssh.passwordAuthentication = false;

  # Ban brute force SSH
  services.fail2ban.enable = true;
}
