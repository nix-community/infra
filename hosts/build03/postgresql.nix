{
  config,
  inputs,
  pkgs,
  ...
}:

{
  imports = [
    inputs.self.nixosModules.backup
  ];

  services.postgresqlBackup = {
    enable = true;
    compression = "none";
    startAt = "daily";
  };

  nixCommunity.backup = [
    {
      name = "postgresql";
      after = [ config.systemd.services.postgresqlBackup.name ];
      paths = [ config.services.postgresqlBackup.location ];
      startAt = "daily";
    }
  ];

  services.postgresql.ensureUsers = [ { name = "telegraf"; } ];

  systemd.services.postgresql-setup.postStart = ''
    psql -tAc 'GRANT pg_read_all_stats TO telegraf' -d postgres
  '';

  services.telegraf.extraConfig.inputs.postgresql = {
    address = "host=/run/postgresql user=telegraf database=postgres";
  };

  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_18;

    enableJIT = true;

    # https://pgtune.leopard.in.ua/#/
    # https://pgconfigurator.cybertec.at/
    # https://github.com/NixOS/infra/blob/4b5dd4f974d3f707b64ad60793b8182e645631ed/build/haumea/postgresql.nix

    settings = {
      # Connectivity
      max_connections = 2000;
      superuser_reserved_connections = 3;

      # https://vadosware.io/post/everything-ive-seen-on-optimizing-postgres-on-zfs-on-linux/#zfs-related-tunables-on-the-postgres-side
      full_page_writes = "off";

      # Memory Settings
      shared_buffers = "32 GB";
      work_mem = "128 MB";
      maintenance_work_mem = "2 GB";
      huge_pages = "off";
      effective_cache_size = "64 GB";
      effective_io_concurrency = 100; # concurrent IO only really activated if OS supports posix_fadvise function
      random_page_cost = 1.25; # speed of random disk access relative to sequential access (1.0)

      # Monitoring
      shared_preload_libraries = "pg_stat_statements"; # per statement resource usage stats
      track_io_timing = "on"; # measure exact block IO times
      track_functions = "pl"; # track execution times of pl-language procedures if any

      # Replication
      wal_level = "replica"; # consider using at least "replica"
      max_wal_senders = 0;
      synchronous_commit = "on";

      # Checkpointing:
      checkpoint_timeout = "15 min";
      checkpoint_completion_target = 0.9;

      # 2x default, hint from service logs
      max_wal_size = "5 GB";
      min_wal_size = "1 GB";

      # WAL writing
      wal_compression = "on";
      wal_buffers = -1; # auto-tuned by Postgres till maximum of segment size (16MB by default)
      wal_writer_delay = "200ms";
      wal_writer_flush_after = "1MB";

      # Background writer
      bgwriter_delay = "200ms";
      bgwriter_lru_maxpages = 100;
      bgwriter_lru_multiplier = 2.0;
      bgwriter_flush_after = 0;

      # Parallel queries:
      max_worker_processes = 24;
      max_parallel_workers_per_gather = 12;
      max_parallel_maintenance_workers = 12;
      max_parallel_workers = 24;
      parallel_leader_participation = "on";

      # Advanced features
      enable_partitionwise_join = "on";
      enable_partitionwise_aggregate = "on";
      max_slot_wal_keep_size = "1000 MB";
      track_wal_io_timing = "on";
      maintenance_io_concurrency = 100;
      wal_recycle = "on";
    };
  };
}
