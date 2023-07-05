{ config, lib, pkgs, ... }:

let
  # A "stanza" is pgBackrest speak for a postgresql cluster
  stanza = "web01";

  mkBackupUnits = { type, onCalendar }: {
    systemd.timers."pgbackrest-${type}" = {
      partOf = [ "pgbackrest-${type}.service" ];
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = onCalendar;
        Unit = "pgbackrest-${type}.service";
      };
    };

    systemd.services."pgbackrest-${type}" = {
      serviceConfig.Type = "oneshot";
      serviceConfig.ExecStart = "${lib.getExe pkgs.pgbackrest} --type=${type} --stanza=${stanza} backup";
      serviceConfig.User = "postgres";
    };
  };

in
lib.mkMerge [
  # Config
  {
    environment.etc."pgbackrest/pgbackrest.conf".text = lib.generators.toINI { } {
      "${stanza}" = {
        pg1-path = config.services.postgresql.dataDir;
      };

      global = {
        repo1-retention-full = 3;
        repo1-type = "cifs";
        repo1-path = "/mnt/pgbackrest";

        # Force a checkpoint to start backup immediately.
        start-fast = "y";
        # Use delta restore.
        delta = "y";

        # Enable ZSTD compression.
        compress-type = "zst";
        compress-level = 6;

        log-level-console = "info";
        log-level-file = "debug";
      };
    };

    services.postgresql.settings = {
      wal_level = "replica";
      max_wal_senders = 3;
      archive_mode = "on";
      archive_command = "${lib.getExe pkgs.pgbackrest} --stanza=${stanza} archive-push %p";
      archive_timeout = 300;
    };

    environment.systemPackages = [
      pkgs.pgbackrest
    ];
  }

  # Full backup weekly
  (mkBackupUnits {
    type = "full";
    onCalendar = "weekly";
  })

  # Differential backup daily
  (mkBackupUnits {
    type = "diff";
    onCalendar = "daily";
  })

  # Incremental backup hourly
  (mkBackupUnits {
    type = "incr";
    onCalendar = "hourly";
  })
]
