{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.nixCommunity.gc.gbFree = lib.mkOption {
    type = lib.types.int;
    default = 150;
    description = "Amount of free space in GB to keep on disk.";
  };

  config.nix.gc.options = ''
    --max-freed "$((${toString config.nixCommunity.gc.gbFree} * 1024**3 - 1024 * $(df -P -k /nix/store | tail -n 1 | ${pkgs.gawk}/bin/awk '{ print $4 }')))"
  '';
}
