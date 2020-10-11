{ pkgs, lib, config, ... }:

let
  userLib = import ../users/lib.nix { inherit lib; };

  sources = import ../nix/sources.nix;
  nixpkgs-update = import sources.nixpkgs-update { };

  nixpkgs-update-bin = "${nixpkgs-update}/bin/nixpkgs-update";

  nixpkgsUpdateSystemDependencies = with pkgs; [
    nix # for nix-shell used by python packges to update fetchers
    git # used by update-scripts
    gnugrep
    curl
  ];

  nixpkgs-update-github-releases = "${sources.nixpkgs-update-github-releases}/main.py";
  nixpkgs-update-pypi-releases = "${sources.nixpkgs-update-pypi-releases}/main.py";

  nixpkgsUpdateServiceConfigCommon = {
    Type = "oneshot";
    User = "r-ryantm";
    Group = "r-ryantm";
    WorkingDirectory = "/var/lib/nixpkgs-update";
    StateDirectory = "nixpkgs-update";
    StateDirectoryMode = "700";
    CacheDirectory = "nixpkgs-update";
    CacheDirectoryMode = "700";
    LogsDirectory = "nixpkgs-update";
    LogsDirectoryMode = "755";
    StandardOutput = "journal";
  };
in
{
  users.groups.r-ryantm = {};
  users.users.r-ryantm = {
    useDefaultShell = true;
    isNormalUser = true; # The hub cli seems to really want stuff to be set up like a normal user
    uid = userLib.mkUid "rrtm";
    extraGroups = [ "r-ryantm" ];
  };

  systemd.services.nixpkgs-update = {
    description = "nixpkgs-update service";
    enable = true;
    restartIfChanged = false;
    path = nixpkgsUpdateSystemDependencies;
    environment.XDG_CONFIG_HOME = "/var/lib/nixpkgs-update";
    environment.XDG_CACHE_HOME = "/var/cache/nixpkgs-update";
    # API_TOKEN is used by nixpkgs-update-github-releases
    environment.API_TOKEN_FILE = "/var/lib/nixpkgs-update/github_token_with_username.txt";
    # Used by nixpkgs-update-github-releases to install python dependencies
    # Used by nixpkgs-update-pypi-releases
    environment.NIX_PATH = "nixpkgs=/var/cache/nixpkgs-update/nixpkgs";

    serviceConfig = nixpkgsUpdateServiceConfigCommon;

    script = ''
      ${nixpkgs-update-bin} delete-done --delete
      grep -rl $XDG_CACHE_HOME/nixpkgs -e buildPython | grep default | \
        ${nixpkgs-update-pypi-releases} --nixpkgs=/var/cache/nixpkgs-update/nixpkgs > /var/lib/nixpkgs-update/packages-to-update.txt
      ${nixpkgs-update-bin} update-list --pr --cve --outpaths --nixpkgs-review
      ${nixpkgs-update-bin} delete-done --delete
      ${nixpkgs-update-github-releases} > /var/lib/nixpkgs-update/packages-to-update.txt
      ${nixpkgs-update-bin} update-list --pr --cve --outpaths --nixpkgs-review
      ${nixpkgs-update-bin} delete-done --delete
      ${nixpkgs-update-bin} fetch-repology > /var/lib/nixpkgs-update/packages-to-update.txt
      ${nixpkgs-update-bin} update-list --pr --cve --outpaths --nixpkgs-review
    '';
  };

  systemd.timers.nixpkgs-update = {
    description = "nixpkgs-update";
    enable = true;
    timerConfig = { OnCalendar = "daily"; };
    wantedBy = [ "timers.target" ];
  };

  services.nginx.virtualHosts."r.ryantm.com" = {
    forceSSL = true;
    enableACME = true;
    locations."/log/" = {
      alias = "/var/log/nixpkgs-update/";
      extraConfig = ''
        charset utf-8;
        autoindex on;
      '';
    };
  };

}
