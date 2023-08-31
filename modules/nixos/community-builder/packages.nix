{ pkgs, ... }:
{
  # useful for people that want to test stuff
  environment.systemPackages = [
    pkgs.fd
    pkgs.git
    pkgs.mosh
    pkgs.nano
    pkgs.nix-output-monitor
    pkgs.nix-tree
    pkgs.nixpkgs-review
    pkgs.ripgrep
    pkgs.tig

    # terminfo packages
    pkgs.foot.terminfo
    pkgs.kitty.terminfo
    pkgs.termite.terminfo
    pkgs.wezterm.terminfo
  ];

  networking.firewall.allowedUDPPortRanges = [
    # Reserved for mosh
    {
      from = 60000;
      to = 61000;
    }
  ];
}
