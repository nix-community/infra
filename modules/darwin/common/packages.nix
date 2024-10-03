{ lib, pkgs, ... }:
{
  # srvos

  programs.vim = {
    enable = true;
    # evaluation warning: 'vam' attribute is deprecated
    package = lib.mkForce pkgs.vim;
  };
}
