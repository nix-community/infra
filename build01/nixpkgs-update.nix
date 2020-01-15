{ pkgs, lib, config, ... }:

let
  userLib = import ../users/lib.nix { inherit lib; };

  sources = import ../nix/sources.nix;
  nixpkgs-update = import sources.nixpkgs-update { returnShellEnv = false; };
  nixpkgsUpdateSystemDependencies = with pkgs; [
    nix
    git
    getent
    gitAndTools.hub
    jq
    tree
    gist
    cachix
  ];

  nixpkgsUpdateServiceConfigCommon = {
    Type = "oneshot";
    User = "r-ryantm";
    Group = "r-ryantm";
    WorkingDirectory = "/var/lib/nixpkgs-update";
    StateDirectory = "nixpkgs-update";
    StateDirectoryMode = "700";
    RuntimeDirectory = "nixpkgs-update";
    RuntimeDirectoryMode = "700";
    CacheDirectory = "nixpkgs-update";
    CacheDirectoryMode = "700";
    StandardOutput="journal";
  };
in {
  users.users.r-ryantm.packages = [ pkgs.cachix ];
  users.groups.r-ryantm = { };
  users.users.r-ryantm = {
    useDefaultShell = true;
    isNormalUser = true; # The hub cli seems to really want stuff to be set up like a normal user
    uid = userLib.mkUid "rrtm";
    extraGroups = [ "r-ryantm" ];
  };
  nix.trustedUsers = [
    "r-ryantm"
  ];


  systemd.services.nixpkgs-update = {
    description = "nixpkgs-update service";
    enable = true;
    path = nixpkgsUpdateSystemDependencies;
    environment.XDG_CONFIG_HOME = "/var/lib/nixpkgs-update";
    environment.XDG_RUNTIME_DIR = "/run/nixpkgs-update";
    environment.XDG_CACHE_HOME = "/var/cache/nixpkgs-update";

    serviceConfig = nixpkgsUpdateServiceConfigCommon;
    script = "${nixpkgs-update}/bin/nixpkgs-update update";
  };

  systemd.services.nixpkgs-update-delete-done = {
    description = "nixpkgs-update delete done branches";
    enable = true;
    path = nixpkgsUpdateSystemDependencies;
    environment.XDG_CONFIG_HOME = "/var/lib/nixpkgs-update";
    environment.XDG_RUNTIME_DIR = "/run/nixpkgs-update";
    environment.XDG_CACHE_HOME = "/var/cache/nixpkgs-update";

    serviceConfig = nixpkgsUpdateServiceConfigCommon;
    script = "${nixpkgs-update}/bin/nixpkgs-update delete-done";
  };

  systemd.timers.nixpkgs-update-delete-done = {
    description = "nixpkgs-update delete done branches";
    enable = true;
    timerConfig = { OnCalendar = "daily"; };
  };

}
