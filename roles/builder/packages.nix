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
    pkgs.tmux
    pkgs.vim

    # terminfo packages
    pkgs.foot.terminfo
    pkgs.kitty.terminfo
    pkgs.termite.terminfo
    pkgs.wezterm.terminfo
  ];
}
