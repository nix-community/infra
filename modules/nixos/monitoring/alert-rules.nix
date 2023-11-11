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
        BuildbotNoWorkers = {
          expr = ''count(buildbot_workers_running{worker_name!="__Janitor"} == 1) by (instance) == 0'';
          annotations.description = "{{$labels.instance}}: buildbot has no workers";
        };

        Filesystem80percentFull.enable = false;

        Filesystem85percentFull = {
          expr = ''disk_used_percent{mode!="ro"} >= 85'';
          for = "10m";
          annotations.description = "{{$labels.host}} device {{$labels.device}} on {{$labels.path}} got less than 15% space left on its filesystem";
        };

        Load15.expr = lib.mkForce ''system_load15 / system_n_cpus{host!~"(build|darwin).*"} >= 2.0'';

        MatrixHookNotRunning = {
          expr = ''systemd_units_active_code{name="matrix-hook.service", sub!="running"}'';
          annotations.description = "{{$labels.host}} should have a running {{$labels.name}}";
        };

        SmartErrors.expr = lib.mkForce ''smart_device_health_ok{enabled!="Disabled", host!~"(build02|build03)"} != 1'';

        TelegrafPluginFailing = {
          expr = ''internal_gather_errors != 0'';
          annotations.description = "{{$labels.instance}}: telegraf plugin {{$labels.input}} is failing";
        };
      };
  };
}
