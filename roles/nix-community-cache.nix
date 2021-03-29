{ config, pkgs, ... }:
let
  postBuildHook = pkgs.writeScript "post-build-hook.sh" ''
    #!${pkgs.runtimeShell}
    export PATH=$PATH:${pkgs.nixFlakes}/bin
    exec ${pkgs.cachix}/bin/cachix -c /var/lib/post-build-hook/nix-community-cachix.dhall push nix-community $OUT_PATHS
  '';

  sockPath = "/run/post-build-hook.sock";

  queueBuildHook = pkgs.writeScript "post-build-hook.sh" ''
    ${pkgs.queued-build-hook}/bin/queued-build-hook queue --socket ${sockPath}
  '';

  sources = import ../nix/sources.nix;

in
{

  nixpkgs.overlays = [
    (self: super: {
      queued-build-hook = (import sources.queued-build-hook { pkgs = super; });
    })
  ];

  systemd.sockets.queued-build-hook = {
    description = "Post-build-hook socket";
    wantedBy = [ "sockets.target" ];
    socketConfig = {
      ListenStream = sockPath;
      SocketUser = "root";
      SocketMode = "0600";
    };
  };

  systemd.services.queued-build-hook = {
    description = "Post-build-hook service";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" "queued-build-hook.socket" ];
    requires = [ "queued-build-hook.socket" ];
    # either cachix or nix want that
    environment.XDG_CACHE_HOME = "/var/cache/queued-build-hook";
    serviceConfig.CacheDirectory = "queued-build-hook";
    serviceConfig.ExecStart = "${pkgs.queued-build-hook}/bin/queued-build-hook daemon --retry-interval 30 --hook ${postBuildHook}";
  };

  nix.extraOptions = ''
    post-build-hook = ${queueBuildHook}
  '';

}
