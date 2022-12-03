{ pkgs, ... }:
{
  # useful for people that want to test stuff
  environment.systemPackages = [
    pkgs.vim
    pkgs.nano # ?
    pkgs.tmux
    pkgs.git
    pkgs.tig
    pkgs.nixpkgs-review
    pkgs.ripgrep
    pkgs.fd
    pkgs.nix-tree
  ];
}
