{
  imports = [ ../shared/remote-builder.nix ];

  users.users.nix = {
    isNormalUser = true;
    group = "nix";
    home = "/var/lib/nix";
    createHome = true;
  };
  users.groups.nix = { };
}
