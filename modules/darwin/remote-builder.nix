{
  imports = [ ../shared/remote-builder.nix ];

  users.knownUsers = [ "nix" ];

  users.users.nix = {
    name = "nix";
    uid = 8765;
    home = "/Users/nix";
    createHome = true;
    shell = "/bin/zsh";
  };
}
