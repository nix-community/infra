{ lib, ... }:
{
  srvos.prometheus = {
    ruleGroups.srvosAlerts.alertRules =
      (lib.genAttrs [
        "borgbackup-job-github-org.service"
        "borgbackup-job-nixpkgs-update.service"
      ]
        (name: {
          expr = ''absent_over_time(task_last_run{name="${name}"}[1d])'';
          annotations.description = "status of ${name} is unknown: no data for a day";
        })) //
      {
        CominDeploymentFailing = {
          expr = ''comin_deployment_status != 2'';
          for = "30m";
          annotations.description = "{{$labels.host}} deployment failing";
        };

        Filesystem80percentFull.enable = false;

        Filesystem90percentFull = {
          expr = ''disk_used_percent{mode!="ro"} >= 90'';
          for = "10m";
          annotations.description = "{{$labels.host}} device {{$labels.device}} on {{$labels.path}} got less than 10% space left on its filesystem";
        };

        Load15.expr = lib.mkForce ''system_load15 / system_n_cpus{host!~"(build|darwin).*"} >= 2.0'';

        MatrixHookNotRunning = {
          expr = ''systemd_units_active_code{name="matrix-hook.service", sub!="running"}'';
          annotations.description = "{{$labels.host}} should have a running {{$labels.name}}";
        };

        OfBorgEvalQueue = {
          expr = ''ofborg_queue_evaluator_waiting > (2 * ofborg_queue_evaluator_consumers)'';
          for = "1h";
          annotations.description = "ofborg evaluator queue is more than 2x the number of evaluators";
        };

        SmartErrors.expr = lib.mkForce ''smart_device_health_ok{enabled!="Disabled", host!="build01"} != 1'';
      };
  };
}
