{ pkgs, ... }:
{
  imports = [
    ./packages.nix
    ./users.nix
  ];

  programs.zsh = {
    # https://grml.org/zsh/grmlzshrc.html
    # https://grml.org/zsh/grml-zsh-refcard.pdf
    interactiveShellInit = ''
      source ${pkgs.grml-zsh-config}/etc/zsh/zshrc
    '';
    promptInit = ""; # otherwise it'll override the grml prompt
  };
}
