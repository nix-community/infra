{ lib, pkgs, ... }:
{
  # srvos

  environment.systemPackages = map lib.lowPrio [
    pkgs.curl
    pkgs.dnsutils
    pkgs.gitMinimal
    pkgs.htop
    pkgs.jq
    pkgs.tmux
  ];

  programs.vim = {
    enable = true;
    # evaluation warning: 'vam' attribute is deprecated
    package = lib.mkForce pkgs.vim;
  };
}
