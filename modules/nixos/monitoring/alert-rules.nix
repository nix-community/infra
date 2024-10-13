{ lib, ... }:
{
  srvos.prometheus = {
    ruleGroups.srvosAlerts.alertRules =
      (lib.genAttrs
        [
          "borgbackup-job-github-org.service"
          "borgbackup-job-nixpkgs-update.service"
        ]
        (name: {
          expr = ''absent_over_time(task_last_run{name="${name}"}[1d])'';
          annotations.description = "status of ${name} is unknown: no data for a day";
        })
      )
      // {
        Filesystem80percentFull.enable = false;

        Filesystem95percentFull = {
          expr = ''disk_used_percent{mode!="ro"} >= 95'';
          for = "10m";
          annotations.description = "{{$labels.host}} device {{$labels.device}} on {{$labels.path}} got less than 5% space left on its filesystem";
        };

        Load15.expr = lib.mkForce ''system_load15 / system_n_cpus{host!~"(build|darwin).*"} >= 2.0'';

        MatrixHookNotRunning = {
          expr = ''systemd_units_active_code{name="matrix-hook.service", sub!="running"}'';
          annotations.description = "{{$labels.host}} should have a running {{$labels.name}}";
        };

        OfBorgEvalQueue = {
          expr = ''ofborg_queue_evaluator_waiting > (3 * ofborg_queue_evaluator_consumers)'';
          for = "1h";
          annotations.description = "ofborg evaluator queue is more than 3x the number of evaluators";
        };
      };
  };
}
