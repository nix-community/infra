{
  services.openssh = {
    hostKeys = [
      {
        path = "/var/lib/secrets/ssh_host_ed25519_key";
        type = "ed25519";
      }
    ];
  };
}
