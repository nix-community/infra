{
  users.users.nix = {
    isNormalUser = true;
    group = "nix";
    home = "/var/lib/nix";
    createHome = true;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEmdo1x1QkRepZf7nSe+OdEWX+wOjkBLF70vX9F+xf68 builder"
    ];
  };
  users.groups.nix = {};
  nix.settings.trusted-users = ["nix"];
}
