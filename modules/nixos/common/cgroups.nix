{ config, lib, ... }:
{
  config = lib.mkIf (lib.hasPrefix "build" config.networking.hostName) {
    nix.settings = {
      experimental-features = [
        "auto-allocate-uids"
        "cgroups"
      ];

      system-features = [ "uid-range" ];

      auto-allocate-uids = true;
      use-cgroups = true;
    };
  };
}
