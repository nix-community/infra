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
    socat # used by worker script
  ];

  mkWorker = name: {
    after = [ "network-online.target" "nixpkgs-update-supervisor.service" ];
    wants = [ "network-online.target" ];
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
      Restart = "on-failure";
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

      socket=/run/nixpkgs-update-supervisor/work.sock

      function run-nixpkgs-update {
        exit_code=0
        set -x
        timeout 6h ${nixpkgs-update-bin} update-batch --pr --outpaths --nixpkgs-review "$attr_path $payload" || exit_code=$?
        set +x
        if [ $exit_code -eq 124 ]; then
          echo "Update was interrupted because it was taking too long."
        fi
        msg="DONE $attr_path $exit_code"
      }

      msg=READY
      while true; do
        response=$(echo "$msg" | socat -t5 UNIX-CONNECT:"$socket" - || true)
        case "$response" in
          "") # connection error; retry
            sleep 5
            ;;
          NOJOBS)
            msg=READY
            sleep 60
            ;;
          JOB\ *)
            read -r attr_path payload <<< "''${response#JOB }"
            # If one worker is initializing the nixpkgs clone, the other will
            # try to use the incomplete clone, consuming a bunch of jobs and
            # throwing them away. So we use a crude locking mechanism to
            # run only one worker when there isn't a nixpkgs directory yet.
            # Once the directory exists and this initial lock is released,
            # multiple workers can run concurrently.
            lockdir="$XDG_CACHE_HOME/.nixpkgs.lock"
            if [ ! -e "$XDG_CACHE_HOME/nixpkgs" ] && mkdir "$lockdir"; then
              trap 'rmdir "$lockdir"' EXIT
              run-nixpkgs-update
              rmdir "$lockdir"
              trap - EXIT
              continue
            fi
            while [ -e "$lockdir" ]; do
              sleep 10
            done
            run-nixpkgs-update
        esac
      done
    '';
  };

  mkFetcher = name: cmd: {
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    path = nixpkgsUpdateSystemDependencies ++ [
      # nixpkgs-update-github-releases
      (pkgs.python3.withPackages (p: with p;
      [ requests dateutil libversion cachecontrol lockfile filelock ]
      ))
    ];
    # API_TOKEN is used by nixpkgs-update-github-releases
    # using a token from another account so the rate limit doesn't block opening PRs
    environment.API_TOKEN_FILE = "${config.sops.secrets.github-token-with-username.path}";
    environment.XDG_CACHE_HOME = "/var/cache/nixpkgs-update/fetcher/";

    serviceConfig = {
      Type = "simple";
      User = "r-ryantm";
      Group = "r-ryantm";
      Restart = "on-failure";
      RestartSec = "30m";
      LogsDirectory = "nixpkgs-update/";
      LogsDirectoryMode = "755";
      StateDirectory = "nixpkgs-update";
      StateDirectoryMode = "700";
      CacheDirectory = "nixpkgs-update/worker";
      CacheDirectoryMode = "700";
    };

    script = ''
      mkdir -p "$LOGS_DIRECTORY/~fetchers"
      cd "$LOGS_DIRECTORY/~fetchers"
      run_name="${name}.$(date +%s).txt"
      rm -f ${name}.*.txt.part
      ${cmd} > "$run_name.part"
      rm -f ${name}.*.txt
      mv "$run_name.part" "$run_name"
    '';
    startAt = "0/12:10"; # every 12 hours
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
    startAt = "0/12:10"; # every 12 hours
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
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

  systemd.services.nixpkgs-update-fetch-repology = mkFetcher "repology" "${nixpkgs-update-bin} fetch-repology";

  systemd.services.nixpkgs-update-fetch-updatescript = mkFetcher "updatescript" "${pkgs.nix}/bin/nix eval --raw -f ${./packages-with-update-script.nix}";
  systemd.services.nixpkgs-update-fetch-github = mkFetcher "github" "${inputs.nixpkgs-update-github-releases}/main.py";

  systemd.services.nixpkgs-update-worker1 = mkWorker "worker1";
  systemd.services.nixpkgs-update-worker2 = mkWorker "worker2";
  systemd.services.nixpkgs-update-worker3 = mkWorker "worker3";
  systemd.services.nixpkgs-update-worker4 = mkWorker "worker4";
  # Too many workers cause out-of-memory.

  systemd.services.nixpkgs-update-supervisor = {
    wantedBy = [ "multi-user.target" ];
    description = "nixpkgs-update supervisor service";
    enable = true;
    restartIfChanged = true;
    path = with pkgs; [
      apacheHttpd
      (python311.withPackages (ps: [ ps.asyncinotify ]))
    ];

    serviceConfig = {
      Type = "simple";
      User = "r-ryantm";
      Group = "r-ryantm";
      Restart = "on-failure";
      RestartSec = "5s";
      LogsDirectory = "nixpkgs-update/";
      LogsDirectoryMode = "755";
      RuntimeDirectory = "nixpkgs-update-supervisor/";
      RuntimeDirectoryMode = "755";
      StandardOutput = "journal";
    };

    script = ''
      mkdir -p "$LOGS_DIRECTORY/~supervisor"
      # This is for public logs at https://r.ryantm.com/log/~supervisor
      exec  > >(rotatelogs -eD "$LOGS_DIRECTORY"'/~supervisor/%Y-%m-%d.stdout.log' 86400)
      exec 2> >(rotatelogs -eD "$LOGS_DIRECTORY"'/~supervisor/%Y-%m-%d.stderr.log' 86400 >&2)
      # Fetcher output is hosted at https://r.ryantm.com/log/~fetchers
      python3.11 ${./supervisor.py} "$LOGS_DIRECTORY/~supervisor/state.db" "$LOGS_DIRECTORY/~fetchers" "$RUNTIME_DIRECTORY/work.sock"
    '';
  };

  systemd.services.nixpkgs-update-delete-old-logs = {
    startAt = "daily";
    # delete logs older than 18 months, delete worker logs older than 3 months, delete empty directories
    script = ''
      ${pkgs.findutils}/bin/find /var/log/nixpkgs-update -type f -mtime +548 -delete
      ${pkgs.findutils}/bin/find /var/log/nixpkgs-update/~workers -type f -mtime +90 -delete
      ${pkgs.findutils}/bin/find /var/log/nixpkgs-update -type d -empty -delete
    '';
    serviceConfig.Type = "oneshot";
  };

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
    owner = "r-ryantm";
    group = "r-ryantm";
  };

  sops.secrets.nix-community-cachix = {
    path = "/home/r-ryantm/.config/cachix/cachix.dhall";
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
