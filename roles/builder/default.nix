{ ... }: {
  imports = [
    ./packages.nix
    ./users.nix
  ];

  programs.fish.enable = true;

  programs.zsh.enable = true;
}
