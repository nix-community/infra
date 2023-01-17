{ pkgs, ... }:
{
  # useful for people that want to test stuff
  environment.systemPackages = [
    pkgs.fd
    pkgs.git
    pkgs.nano
    pkgs.nix-tree
    pkgs.nixpkgs-review
    pkgs.ripgrep
    pkgs.tig
    pkgs.tmux
    pkgs.vim
  ];
}
