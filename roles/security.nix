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

  services.openssh.kbdInteractiveAuthentication = false;
  services.openssh.passwordAuthentication = false;

  programs.ssh.knownHosts = {
    github-rsa = {
      extraHostNames = [ "github.com" ];
      publicKey = "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==";
    };
    github-ed25519 = {
      extraHostNames = [ "github.com" ];
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
    };
    build01 = {
      hostNames = ["build01.nix-community.org"];
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIElIQ54qAy7Dh63rBudYKdbzJHrrbrrMXLYl7Pkmk88H";
    };
    build02 = {
      hostNames = ["build02.nix-community.org"];
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMm3/o1HguyRL1z/nZxLBY9j/YUNXeNuDoiBLZAyt88Z";
    };
    build03 = {
      hostNames = ["build03.nix-community.org"];
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFiozp1A1+SUfJQPa5DZUQcVc6CZK2ZxL6FJtNdh+2TP";
    };
    build04 = {
      hostNames = ["build04.nix-community.org"];
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPU/gbREwVuI1p3ag1iG72jxl2/92yGl38c+TPOfFMH8";
    };
  };

  # Ban brute force SSH
  services.fail2ban.enable = true;
}
