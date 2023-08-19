{ lib }:
lib.mapAttrsToList
  (name: opts: {
    alert = name;
    expr = opts.condition;
    for = opts.time or "2m";
    labels = { };
    annotations.description = opts.description;
    # for matrix alert-receiver
    annotations.summary = opts.description;
  })
  ((lib.genAttrs [
    "borgbackup-job-github-org.service"
    "borgbackup-job-nixpkgs-update.service"
  ]
    (name: {
      condition = ''absent_over_time(task_last_run{name="${name}"}[1d])'';
      description = "status of ${name} is unknown: no data for a day";
    })
  ) // {
    prometheus_too_many_restarts = {
      condition = ''changes(process_start_time_seconds{job=~"prometheus|pushgateway|alertmanager|telegraf"}[15m]) > 2'';
      description = "Prometheus has restarted more than twice in the last 15 minutes. It might be crashlooping";
    };

    alert_manager_config_not_synced = {
      condition = ''count(count_values("config_hash", alertmanager_config_hash)) > 1'';
      description = "Configurations of AlertManager cluster instances are out of sync";
    };

    #alert_manager_e2e_dead_man_switch = {
    #  condition = "vector(1)";
    #  description = "Prometheus DeadManSwitch is an always-firing alert. It's used as an end-to-end test of Prometheus through the Alertmanager.";
    #};

    prometheus_not_connected_to_alertmanager = {
      condition = "prometheus_notifications_alertmanagers_discovered < 1";
      description = "Prometheus cannot connect the alertmanager\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}";
    };

    prometheus_rule_evaluation_failures = {
      condition = "increase(prometheus_rule_evaluation_failures_total[3m]) > 0";
      description = "Prometheus encountered {{ $value }} rule evaluation failures, leading to potentially ignored alerts.\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}";
    };

    prometheus_template_expansion_failures = {
      condition = "increase(prometheus_template_text_expansion_failures_total[3m]) > 0";
      time = "0m";
      description = "Prometheus encountered {{ $value }} template text expansion failures\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}";
    };

    filesystem_full_80percent = {
      condition = ''disk_used_percent{mode!="ro"} >= 80'';
      time = "10m";
      description = "{{$labels.host}} device {{$labels.device}} on {{$labels.path}} got less than 20% space left on its filesystem";
    };

    filesystem_inodes_full = {
      condition = ''disk_inodes_free / disk_inodes_total < 0.10'';
      time = "10m";
      description = "{{$labels.host}} device {{$labels.device}} on {{$labels.path}} got less than 10% inodes left on its filesystem";
    };

    daily_task_not_run = {
      # give 6 hours grace period
      condition = ''time() - task_last_run{state="ok",frequency="daily"} > (24 + 6) * 60 * 60'';
      description = "{{$labels.host}}: {{$labels.name}} was not run in the last 24h";
    };

    daily_task_failed = {
      condition = ''task_last_run{state="fail"}'';
      description = "{{$labels.host}}: {{$labels.name}} failed to run";
    };

    nixpkgs_out_of_date = {
      condition = ''(time() - flake_input_last_modified{input="nixpkgs"}) / (60*60*24) > 7'';
      description = "{{$labels.host}}: nixpkgs flake is older than a week";
    };

    swap_using_30percent = {
      condition = ''mem_swap_total - (mem_swap_cached + mem_swap_free) > mem_swap_total * 0.3'';
      time = "30m";
      description = "{{$labels.host}} is using 30% of its swap space for at least 30 minutes";
    };

    # user@$uid.service and similar sometimes fail, we don't care about those services.
    systemd_service_failed = {
      condition = ''systemd_units_active_code{name!~"user@\\d+.service"} == 3'';
      description = "{{$labels.host}} failed to (re)start service {{$labels.name}}";
    };

    matrix_hook_not_running = {
      condition = ''systemd_units_active_code{name="matrix-hook.service", sub!="running"}'';
      description = "{{$labels.host}} should have a running {{$labels.name}}";
    };

    ram_using_95percent = {
      condition = "mem_buffered + mem_free + mem_cached < mem_total * 0.05";
      time = "1h";
      description = "{{$labels.host}} is using at least 95% of its RAM for at least 1 hour";
    };

    load15 = {
      condition = ''system_load15 / system_n_cpus{host!~"(build|darwin).*"} >= 2.0'';
      time = "10m";
      description = "{{$labels.host}} is running with load15 > 1 for at least 5 minutes: {{$value}}";
    };

    localhost_reboot = {
      condition = ''system_uptime{instance="localhost:9273"} < 900'';
      description = "{{$labels.host}} just rebooted";
    };

    reboot = {
      condition = ''system_uptime{instance!="localhost:9273"} < 300'';
      description = "{{$labels.host}} just rebooted";
    };

    uptime = {
      condition = ''system_uptime > (60*60*24*14)'';
      description = "Uptime monster: {{$labels.host}} has been up for more than 14 days";
    };

    telegraf_down = {
      condition = ''min(up{job=~"telegraf"}) by (job, instance, org) == 0'';
      time = "3m";
      description = "{{$labels.host}}: telegraf exporter is down";
    };

    http = {
      condition = "http_response_result_code != 0";
      description = "{{$labels.server}} : http request failed from {{$labels.host}}: {{$labels.result}}";
    };

    http_match_failed = {
      condition = "http_response_response_string_match == 0";
      description = "{{$labels.server}} : http body not as expected; status code: {{$labels.status_code}}";
    };

    connection_failed = {
      condition = "net_response_result_code != 0";
      description = "{{$labels.server}}: connection to {{$labels.port}}({{$labels.protocol}}) failed from {{$labels.host}}";
    };

    zfs_errors = {
      condition = "zfs_arcstats_l2_io_error + zfs_dmu_tx_error + zfs_arcstats_l2_writes_error > 0";
      description = "{{$labels.host}} reports: {{$value}} ZFS IO errors";
    };

    zpool_status = {
      condition = "zpool_status_errors > 0";
      description = "{{$labels.host}} reports: zpool {{$labels.name}} has {{$value}} errors";
    };

    mdraid_degraded_disks = {
      condition = "mdstat_degraded_disks > 0";
      description = "{{$labels.host}}: raid {{$labels.dev}} has failed disks";
    };

    # ignore devices that disabled S.M.A.R.T (example if attached via USB)
    # Also ignore build02, build03
    smart_errors = {
      condition = ''smart_device_health_ok{enabled!="Disabled", host!~"(build02|build03)"} != 1'';
      description = "{{$labels.host}}: S.M.A.R.T reports: {{$labels.device}} ({{$labels.model}}) has errors";
    };

    oom_kills = {
      condition = "increase(kernel_vmstat_oom_kill[5m]) > 0";
      description = "{{$labels.host}}: OOM kill detected";
    };

    unusual_disk_read_latency = {
      condition = "rate(diskio_read_time[1m]) / rate(diskio_reads[1m]) > 0.1 and rate(diskio_reads[1m]) > 0";
      description = "{{$labels.host}}: Disk latency is growing (read operations > 100ms)";
    };

    unusual_disk_write_latency = {
      condition = "rate(diskio_write_time[1m]) / rate(diskio_write[1m]) > 0.1 and rate(diskio_write[1m]) > 0";
      description = "{{$labels.host}}: Disk latency is growing (write operations > 100ms)";
    };

    ipv6_dad_check = {
      condition = "ipv6_dad_failures_count > 0";
      description = "{{$labels.host}}: {{$value}} assigned ipv6 addresses have failed duplicate address check";
    };

    host_memory_under_memory_pressure = {
      condition = "rate(node_vmstat_pgmajfault[1m]) > 1000";
      description = "{{$labels.host}}: The node is under heavy memory pressure. High rate of major page faults: {{$value}}";
    };

    ext4_errors = {
      condition = "ext4_errors_value > 0";
      description = "{{$labels.host}}: ext4 has reported {{$value}} I/O errors: check /sys/fs/ext4/*/errors_count";
    };

    alerts_silences_changed = {
      condition = ''abs(delta(alertmanager_silences{state="active"}[1h])) >= 1'';
      description = "alertmanager: number of active silences has changed: {{$value}}";
    };
  })
