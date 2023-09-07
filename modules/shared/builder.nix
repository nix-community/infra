{ pkgs, ... }:
let
  asGB = size: toString (size * 1024 * 1024 * 1024);
in
{
  nix.gc.options = ''
    --max-freed "$((${asGB 50} * 1024**3 - 1024 * $(df -P -k /nix/store | tail -n 1 | ${pkgs.gawk}/bin/awk '{ print $4 }')))"
  '';
}
