{ pkgs, lib, inputs, config, ... }:
let
  userLib = import "${toString inputs.self}/users/lib.nix" { inherit lib; };

  nixpkgs-update-bin = "/var/lib/nixpkgs-update/bin/nixpkgs-update";

  nixpkgsUpdateSystemDependencies = with pkgs; [
    nix # for nix-shell used by python packges to update fetchers
    git # used by update-scripts
    openssh # used by git
    gnugrep
    gnused
    curl
    getent # used by hub
    cachix
    apacheHttpd # for rotatelogs, used by worker script
  ];

  nixpkgs-update-github-releases' = "${inputs.nixpkgs-update-github-releases}/main.py";

  mkWorker = name: {
    after = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    description = "nixpkgs-update ${name} service";
    enable = true;
    restartIfChanged = true;
    path = nixpkgsUpdateSystemDependencies;
    environment.XDG_CONFIG_HOME = "/var/lib/nixpkgs-update/worker";
    environment.XDG_CACHE_HOME = "/var/cache/nixpkgs-update/worker";
    environment.XDG_RUNTIME_DIR = "/run/nixpkgs-update-worker"; # for nix-update update scripts

    serviceConfig = {
      Type = "simple";
      User = "r-ryantm";
      Group = "r-ryantm";
      Restart = "on-abort";
      RestartSec = "5s";
      WorkingDirectory = "/var/lib/nixpkgs-update/worker";
      StateDirectory = "nixpkgs-update/worker";
      StateDirectoryMode = "700";
      CacheDirectory = "nixpkgs-update/worker";
      CacheDirectoryMode = "700";
      LogsDirectory = "nixpkgs-update/";
      LogsDirectoryMode = "755";
      RuntimeDirectory = "nixpkgs-update-worker";
      RuntimeDirectoryMode = "700";
      StandardOutput = "journal";
    };

    script = ''
      mkdir -p "$LOGS_DIRECTORY/~workers/"
      # This is for public logs at https://r.ryantm.com/log/~workers
      exec  > >(rotatelogs -eD "$LOGS_DIRECTORY"'/~workers/%Y-%m-%d-${name}.stdout.log' 86400)
      exec 2> >(rotatelogs -eD "$LOGS_DIRECTORY"'/~workers/%Y-%m-%d-${name}.stderr.log' 86400 >&2)

      pipe=/var/lib/nixpkgs-update/fifo

      if [[ ! -p $pipe ]]; then
        mkfifo $pipe || true
      fi

      exec 8<$pipe
      while true
      do
        if read -u 8 line; then
          set -x
          ${nixpkgs-update-bin} update-batch --pr --outpaths --nixpkgs-review "$line" || true
          set +x
        fi
      done
    '';
  };

  mkFetcher = cmd: {
    after = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    path = nixpkgsUpdateSystemDependencies;
    # API_TOKEN is used by nixpkgs-update-github-releases
    environment.API_TOKEN_FILE = "/var/lib/nixpkgs-update/github_token_with_username.txt";
    # Used by nixpkgs-update-github-releases to install python dependencies
    environment.NIX_PATH = "nixpkgs=/var/cache/nixpkgs-update/fetcher/nixpkgs";
    environment.XDG_CACHE_HOME = "/var/cache/nixpkgs-update/fetcher/";

    serviceConfig = {
      Type = "simple";
      User = "r-ryantm";
      Group = "r-ryantm";
      Restart = "on-abort";
      RestartSec = "5s";
      WorkingDirectory = "/var/lib/nixpkgs-update/";
      StateDirectory = "nixpkgs-update";
      StateDirectoryMode = "700";
      CacheDirectory = "nixpkgs-update/worker";
      CacheDirectoryMode = "700";
    };
    script = ''
      pipe=/var/lib/nixpkgs-update/fifo

      if [[ ! -p $pipe ]]; then
        mkfifo $pipe || true
      fi

      ${cmd} | sort -R > $pipe
    '';
  };

in
{
  users.groups.r-ryantm = { };
  users.users.r-ryantm = {
    useDefaultShell = true;
    isNormalUser = true; # The hub cli seems to really want stuff to be set up like a normal user
    uid = userLib.mkUid "rrtm";
    extraGroups = [ "r-ryantm" ];
  };

  systemd.services.nixpkgs-update-delete-done = {
    startAt = "daily";
    after = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    description = "nixpkgs-update delete done branches";
    restartIfChanged = true;
    path = nixpkgsUpdateSystemDependencies;
    environment.XDG_CONFIG_HOME = "/var/lib/nixpkgs-update/worker";
    environment.XDG_CACHE_HOME = "/var/cache/nixpkgs-update/worker";

    serviceConfig = {
      Type = "simple";
      User = "r-ryantm";
      Group = "r-ryantm";
      Restart = "on-abort";
      RestartSec = "5s";
      WorkingDirectory = "/var/lib/nixpkgs-update/worker";
      StateDirectory = "nixpkgs-update/worker";
      StateDirectoryMode = "700";
      CacheDirectoryMode = "700";
      LogsDirectory = "nixpkgs-update/";
      LogsDirectoryMode = "755";
      StandardOutput = "journal";
    };

    script = "${nixpkgs-update-bin} delete-done --delete";
  };

  systemd.services.nixpkgs-update-fetch-repology = mkFetcher "${nixpkgs-update-bin} fetch-repology";
  systemd.services.nixpkgs-update-fetch-updatescript = mkFetcher "${pkgs.nix}/bin/nix eval --raw -f ${./packages-with-update-script.nix}";
  systemd.services.nixpkgs-update-fetch-github = mkFetcher nixpkgs-update-github-releases';

  systemd.services.nixpkgs-update-worker1 = mkWorker "worker1";
  systemd.services.nixpkgs-update-worker2 = mkWorker "worker2";
  # Too many workers cause out-of-memory.
  #systemd.services.nixpkgs-update-worker3 = mkWorker "worker3";
  #systemd.services.nixpkgs-update-worker4 = mkWorker "worker4";

  systemd.tmpfiles.rules = [
    "L+ /home/r-ryantm/.gitconfig - - - - ${./gitconfig.txt}"
    "d /home/r-ryantm/.ssh 700 r-ryantm r-ryantm - -"

    "e /var/cache/nixpkgs-update/worker/nixpkgs-review - - - 1d -"

    "d /var/lib/nixpkgs-update/bin/ 700 r-ryantm r-ryantm - -"
    "L+ ${nixpkgs-update-bin} - - - - ${inputs.nixpkgs-update.packages.${pkgs.system}.default}/bin/nixpkgs-update"
    "L+ /var/lib/nixpkgs-update/worker/github_token.txt - - - - ${config.sops.secrets.github-r-ryantm-token.path}"
    "d /var/lib/nixpkgs-update/worker/cachix/ 700 r-ryantm r-ryantm - -"
    "L+ /var/lib/nixpkgs-update/worker/cachix/cachix.dhall - - - - ${config.sops.secrets.nix-community-cachix.path}"
  ];

  sops.secrets.github-r-ryantm-key = {
    path = "/home/r-ryantm/.ssh/id_rsa";
    owner = "r-ryantm";
    group = "r-ryantm";
  };

  sops.secrets.github-r-ryantm-token = {
    path = "/var/lib/nixpkgs-update/github_token.txt";
    owner = "r-ryantm";
    group = "r-ryantm";
  };

  sops.secrets.github-token-with-username = {
    path = "/var/lib/nixpkgs-update/github_token_with_username.txt";
    owner = "r-ryantm";
    group = "r-ryantm";
  };

  sops.secrets.nix-community-cachix = {
    path = "/home/r-ryantm/.config/cachix/cachix.dhall";
    sopsFile = "${toString inputs.self}/modules/nixos/cachix/secrets.yaml";
    owner = "r-ryantm";
    group = "r-ryantm";
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
