{ config, pkgs, lib, ... }:

{

  # Allow sudo from SSH authenticated users
  # This requires users in the wheel group to log in
  # over ssh with an agent and enable forwarding
  security.pam.services.sudo.sshAgentAuth = true;
  security.pam.enableSSHAgentAuth = true;

  # Dont let users create their own authorized keys files
  services.openssh.authorizedKeysFiles = lib.mkForce [
    "/etc/ssh/authorized_keys.d/%u"
  ];

  networking.firewall.enable = true;

  services.openssh.challengeResponseAuthentication = false;
  services.openssh.passwordAuthentication = false;

  # Ban brute force SSH
  services.fail2ban.enable = true;

}
