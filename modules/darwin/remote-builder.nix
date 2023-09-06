{
  imports = [
    ../shared/remote-builder.nix
  ];

  users.knownUsers = [ "nix" ];

  users.users.nix = {
    name = "nix";
    uid = 8765;
    home = "/Users/nix";
    createHome = true;
    shell = "/bin/zsh";
  };

  # add build user to group for ssh access
  system.activationScripts.postActivation.text = ''
    dseditgroup -o edit -a "nix" -t user com.apple.access_ssh
  '';
}
