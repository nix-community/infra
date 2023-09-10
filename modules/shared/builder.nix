{ pkgs, ... }:
{
  nix.gc.options = ''
    --max-freed "$((50 * 1024**3 - 1024 * $(df -P -k /nix/store | tail -n 1 | ${pkgs.gawk}/bin/awk '{ print $4 }')))"
  '';
}
