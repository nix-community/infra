{
  pkgs,
  lib,
  inputs,
  config,
  ...
}:
let
  userLib = import "${inputs.self}/users/lib.nix" { inherit lib; };

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

    coreutils
    gist
    # https://github.com/Mic92/nixpkgs-review/issues/446
    (nixpkgs-review.overrideAttrs (_: {
      name = "nixpkgs-review-2.12.0";
      version = "2.12.0";
      src = fetchFromGitHub {
        owner = "Mic92";
        repo = "nixpkgs-review";
        tag = "2.12.0";
        hash = "sha256-yNdBqL3tceuoUHx8/j2y5ZTq1zeVDAm37RZtlCbC6rg=";
      };
    }))
    tree
  ];

  mkWorker = name: {
    after = [
      "network-online.target"
      config.systemd.services.nixpkgs-update-supervisor.name
    ];
    wants = [ "network-online.target" ];
    wantedBy = [ config.systemd.targets.multi-user.name ];
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

    environment.NIXPKGS_UPDATE_BIN = nixpkgs-update-bin;
    environment.WORKER_NAME = name;

    script = builtins.readFile ./worker.bash;
  };

  mkFetcher = name: cmd: {
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    path = nixpkgsUpdateSystemDependencies ++ [
      # nixpkgs-update-github-releases
      (pkgs.python3.withPackages (
        p: with p; [
          requests
          dateutil
          libversion
          cachecontrol
          lockfile
          filelock
        ]
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
      CacheDirectory = "nixpkgs-update/fetcher";
      CacheDirectoryMode = "700";
    };

    script = ''
      mkdir -p "$LOGS_DIRECTORY/~fetchers"
      cd "$LOGS_DIRECTORY/~fetchers"
      run_name="${name}.$(date +%s).txt"
      rm -f ${name}.*.txt.part
      ${cmd} | sed -f ${./filter.sed} > "$run_name.part"
      rm -f ${name}.*.txt
      mv "$run_name.part" "$run_name"
    '';
    startAt = "0/12:10"; # every 12 hours
  };

  repology = pkgs.writeShellApplication {
    name = "repology";
    runtimeInputs = [
      pkgs.jq
      pkgs.moreutils
    ];
    text = builtins.readFile ./repology.bash;
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

  systemd.services.nixpkgs-update-fetch-github = mkFetcher "github" "${inputs.nixpkgs-update-github-releases}/main.py";
  systemd.services.nixpkgs-update-fetch-repology = mkFetcher "repology" (lib.getExe repology);
  systemd.services.nixpkgs-update-fetch-updatescript = mkFetcher "updatescript" "${pkgs.nix}/bin/nix eval --option max-call-depth 100000 --raw -f ${./packages-with-update-script.nix}";

  systemd.services.nixpkgs-update-worker1 = mkWorker "worker1";
  systemd.services.nixpkgs-update-worker2 = mkWorker "worker2";
  systemd.services.nixpkgs-update-worker3 = mkWorker "worker3";
  systemd.services.nixpkgs-update-worker4 = mkWorker "worker4";
  systemd.services.nixpkgs-update-worker5 = mkWorker "worker5";
  # Too many workers cause out-of-memory.

  systemd.services.nixpkgs-update-supervisor = {
    wantedBy = [ config.systemd.targets.multi-user.name ];
    description = "nixpkgs-update supervisor service";
    enable = true;
    restartIfChanged = true;
    path = with pkgs; [
      apacheHttpd
      (python3.withPackages (ps: [ ps.asyncinotify ]))
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
      # This is for public logs at nixpkgs-update-logs.nix-community.org/~supervisor
      exec  > >(rotatelogs -eD "$LOGS_DIRECTORY"'/~supervisor/%Y-%m-%d.stdout.log' 86400)
      exec 2> >(rotatelogs -eD "$LOGS_DIRECTORY"'/~supervisor/%Y-%m-%d.stderr.log' 86400 >&2)
      # Fetcher output is hosted at nixpkgs-update-logs.nix-community.org/~fetchers
      python3 ${./supervisor.py} "$LOGS_DIRECTORY/~supervisor/state.db" "$LOGS_DIRECTORY/~fetchers" "$RUNTIME_DIRECTORY/work.sock"
    '';
  };

  systemd.services.nixpkgs-update-queue = {
    after = [ config.systemd.services.nixpkgs-update-supervisor.name ];
    wantedBy = [ config.systemd.targets.multi-user.name ];

    serviceConfig = {
      Type = "simple";
      User = "r-ryantm";
      Group = "r-ryantm";
      Restart = "on-failure";
      RestartSec = "5s";
      LogsDirectory = "nixpkgs-update/";
      LogsDirectoryMode = "755";
      RuntimeDirectory = "nixpkgs-update-queue";
      RuntimeDirectoryMode = "755";
    };

    path = [ pkgs.python3 ];

    script = ''
      cd "$LOGS_DIRECTORY/~supervisor"
      python3 ${./update_queue.py}
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
    "L+ ${nixpkgs-update-bin} - - - - ${
      inputs.nixpkgs-update.packages.${pkgs.system}.default
    }/bin/nixpkgs-update"
  ];

  sops.secrets.github-r-ryantm-key = {
    path = "/home/r-ryantm/.ssh/id_rsa";
    owner = "r-ryantm";
    group = "r-ryantm";
  };

  sops.secrets.github-r-ryantm-token = {
    path = "/var/lib/nixpkgs-update/worker/github_token.txt";
    owner = "r-ryantm";
    group = "r-ryantm";
  };

  sops.secrets.github-token-with-username = {
    owner = "r-ryantm";
    group = "r-ryantm";
  };

  services.nginx.virtualHosts."nixpkgs-update-logs.nix-community.org" = {
    locations."/" = {
      alias = "/var/log/nixpkgs-update/";
      extraConfig = ''
        charset utf-8;
        autoindex on;
      '';
    };
  };

  # TODO: permanent redirect r.ryantm.com/log/ -> nixpkgs-update-logs.nix-community.org
  services.nginx.virtualHosts."r.ryantm.com" = {
    locations."/log/" = {
      alias = "/var/log/nixpkgs-update/";
      extraConfig = ''
        charset utf-8;
        autoindex on;
      '';
    };
  };

}
