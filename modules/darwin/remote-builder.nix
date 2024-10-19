{
  imports = [ ../shared/remote-builder.nix ];

  users.users.nix = {
    name = "nix";
    isNormalUser = true;
    home = "/Users/nix";
    createHome = true;
    # build user should always use the system default shell
    shell = "/bin/zsh";
  };
}
