{ config, pkgs, lib, ... }:
let
  configFile = "/var/lib/post-build-hook/nix-community-cachix.dhall";

in
{
  systemd.services.cachix-watch-store = {
    description = "Cachix store watcher service";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    path = [ config.nix.package ];
    # either cachix or nix want that
    environment.XDG_CACHE_HOME = "/var/cache/cachix-watch-store";
    serviceConfig = {
      Restart = "always";
      CacheDirectory = "cachix-watch-store";
      ExecStart = "${pkgs.cachix}/bin/cachix -c ${configFile} watch-store nix-community";
    };
  };
}
