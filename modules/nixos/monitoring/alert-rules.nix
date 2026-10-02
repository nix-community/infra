{ lib, ... }:
{
  srvos.prometheus = {
    ruleGroups.srvosAlerts.alertRules =
      (lib.genAttrs
        [
          "borgbackup-job-github-org.service"
          "borgbackup-job-postgresql.service"
        ]
        (name: {
          expr = ''absent_over_time(task_last_run{name="${name}"}[1d])'';
          annotations.description = "status of ${name} is unknown: no data for a day";
        })
      )
      // {
        HourlyTaskNotRun = {
          expr = ''time() - task_last_run{state="ok",frequency="hourly"} > 60 * 60'';
          for = "1h";
          annotations.description = "{{$labels.host}}: {{$labels.name}} was not run in the last hour";
        };

        Load15.expr = lib.mkForce ''system_load15 / system_n_cpus{host!~"(build|darwin).*"} >= 2.0'';

        RASDaemon = {
          # https://github.com/influxdata/telegraf/blob/4617e281b0458df847ef5ab57dedf682df843a68/plugins/inputs/ras/README.md#L64
          # processor_base_errors is an aggregate counter
          expr = ''
            increase(ras_cache_l0_l1_errors[15m]) > 0 or
            increase(ras_cache_l2_errors[15m]) > 0 or
            increase(ras_external_mce_errors[15m]) > 0 or
            increase(ras_frc_errors[15m]) > 0 or
            increase(ras_internal_parity_errors[15m]) > 0 or
            increase(ras_internal_timer_errors[15m]) > 0 or
            increase(ras_memory_ecc_corrected_errors[15m]) > 0 or
            increase(ras_memory_ecc_uncorrectable_errors[15m]) > 0 or
            increase(ras_memory_read_corrected_errors[15m]) > 0 or
            increase(ras_memory_read_uncorrectable_errors[15m]) > 0 or
            increase(ras_memory_write_corrected_errors[15m]) > 0 or
            increase(ras_memory_write_uncorrectable_errors[15m]) > 0 or
            increase(ras_microcode_rom_parity_errors[15m]) > 0 or
            increase(ras_processor_bus_errors[15m]) > 0 or
            increase(ras_smm_handler_code_access_violation_errors[15m]) > 0 or
            increase(ras_tlb_instruction_errors[15m]) > 0 or
            increase(ras_unclassified_mce_errors[15m]) > 0 or
            increase(ras_upi_errors[15m]) > 0
          '';
          annotations.description = "RAS daemon reports new errors in the last 15 minutes";
        };

        Reboot.expr = lib.mkForce ''system_uptime{host!="nixbsd-freebsd"} < 300'';

        MatrixHookNotRunning = {
          expr = ''systemd_units_active_code{name="matrix-hook.service", sub!="running"}'';
          annotations.description = "{{$labels.host}} should have a running {{$labels.name}}";
        };

        NixpkgsOutOfDate = lib.mkForce {
          expr = ''(time() - flake_input_last_modified{input="nixpkgs"}) / (60*60*24) > 14'';
          annotations.description = "{{$labels.host}}: nixpkgs flake is older than two weeks";
        };

        SmartErrors.expr = lib.mkForce ''smart_device_health_ok{enabled!="Disabled", host!="build05"} != 1'';
      };
  };
}
