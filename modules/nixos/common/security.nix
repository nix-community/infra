{
  # Make sure that the firewall is enabled, even if it's the default.
  networking.firewall.enable = true;

  services.openssh = {
    hostKeys = [
      { path = "/etc/ssh/ssh_host_ed25519_key"; type = "ed25519"; }
    ];
  };
}
