{
  # Make sure that the firewall is enabled, even if it's the default.
  networking.firewall.enable = true;

  networking.nftables.enable = true;

  # allow to access emergency shell with a password
  boot.initrd.systemd.emergencyAccess = "$6$he2fblfl/H7I.kvz$WbSCMXu8ztmqfj5jG4czqvu/rkMHxufxqHgy1urzXFSN.jZB4QiW5lOjR08vk8pZTyim3TT1wFkMaNE9zZ3sc1";

  services.openssh = {
    hostKeys = [
      {
        path = "/var/lib/ssh_secrets/ssh_host_ed25519_key";
        type = "ed25519";
      }
    ];
  };
}
