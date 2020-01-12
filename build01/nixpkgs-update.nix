{ pkgs, lib, config, ... }:

let
  userLib = import ../users/lib.nix { inherit lib; };

  nixpkgs-update-src = pkgs.fetchFromGitHub {
    owner = "ryantm";
    repo = "nixpkgs-update";
    rev = "02e6ccfd26572269e23dc46df615ee48aec470ca";
    sha256 = "0rw1rzd9x3b4r6xjr2m7hd3xmyji26znn6lk83x1m1fnds10b6jr";
  };
  nixpkgs-update = import nixpkgs-update-src { };
  nixpkgsUpdateSystemDependencies = with pkgs; [
    nix
    git
    getent
    gitAndTools.hub
    jq
    tree
    gist
  ];

  nixpkgsUpdateServiceConfigCommon = {
    Type = "oneshot";
    User = "r-ryantm";
    Group = "r-ryantm";
    StateDirectory = "nixpkgs-update";
    StateDirectoryMode = "700";
    RuntimeDirectory = "nixpkgs-update";
    RuntimeDirectoryMode = "700";
    CacheDirectory = "nixpkgs-update";
    CacheDirectoryMode = "700";
  };
in {
  users.groups.r-ryantm = { };
  users.users.r-ryantm = {
    useDefaultShell = true;
    uid = userLib.mkUid "rrtm";
    extraGroups = [ "r-ryantm" ];
  };

  systemd.services.nixpkgs-update = {
    description = "nixpkgs-update service";
    enable = true;
    path = nixpkgsUpdateSystemDependencies;

    serviceConfig = nixpkgsUpdateServiceConfigCommon;
    script = "${nixpkgs-update}/bin/nixpkgs-update update";
  };

  systemd.services.nixpkgs-update-delete-done = {
    description = "nixpkgs-update delete done branches";
    enable = true;
    path = nixpkgsUpdateSystemDependencies;

    serviceConfig = nixpkgsUpdateServiceConfigCommon;
    script = "${nixpkgs-update}/bin/nixpkgs-update delete-done";
  };

  systemd.timers.nixpkgs-update-delete-done = {
    description = "nixpkgs-update delete done branches";
    enable = true;
    timerConfig = { OnCalendar = "daily"; };
  };

}
