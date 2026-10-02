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
          expr = ''{__name__=~"ras_.*"} != 0'';
          annotations.description = "RAS daemon reports a non-zero value";
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
