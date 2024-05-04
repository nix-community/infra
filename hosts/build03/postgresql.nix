{ pkgs, ... }:

{
  services.postgresql.ensureUsers = [{
    name = "telegraf";
  }];

  systemd.services.postgresql.postStart = ''
    $PSQL -tAc 'GRANT pg_read_all_stats TO telegraf' -d postgres
  '';

  services.telegraf.extraConfig.inputs.postgresql = {
    address = "host=/run/postgresql user=telegraf database=postgres";
  };

  services.postgresql = {
    enable = true;
    # enableJIT seems to be broken, can't set a version without also needing to add withJIT
    package = pkgs.postgresql_15.withJIT;

    enableJIT = true;

    # From https://pgconfigurator.cybertec.at/
    settings = {
      # Connectivity
      max_connections = 500;
      superuser_reserved_connections = 3;

      # Memory Settings
      shared_buffers = "8 GB";
      work_mem = "32 MB";
      maintenance_work_mem = "420 MB";
      huge_pages = "off";
      effective_cache_size = "22 GB";
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
      max_wal_size = "2 GB";
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
      max_worker_processes = 8;
      max_parallel_workers_per_gather = 4;
      max_parallel_maintenance_workers = 4;
      max_parallel_workers = 8;
      parallel_leader_participation = "on";

      # Advanced features
      enable_partitionwise_join = "on";
      enable_partitionwise_aggregate = "on";
      jit = "on";
      max_slot_wal_keep_size = "1000 MB";
      track_wal_io_timing = "on";
      maintenance_io_concurrency = 100;
      wal_recycle = "on";
    };
  };
}
