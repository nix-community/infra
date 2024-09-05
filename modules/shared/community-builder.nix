{ pkgs, ... }:
{
  # useful for people that want to test stuff
  environment.systemPackages = [
    pkgs.fd
    pkgs.git
    pkgs.nano
    pkgs.nix-output-monitor
    pkgs.nix-tree
    pkgs.nixpkgs-review
    pkgs.ripgrep
    pkgs.tig
  ];

  programs.nix-index-database.comma.enable = true;

  programs.zsh = {
    enable = true;
    # https://grml.org/zsh/grmlzshrc.html
    # https://grml.org/zsh/grml-zsh-refcard.pdf
    interactiveShellInit = ''
      source ${pkgs.grml-zsh-config}/etc/zsh/zshrc
    '';
    promptInit = ""; # otherwise it'll override the grml prompt
  };
}
