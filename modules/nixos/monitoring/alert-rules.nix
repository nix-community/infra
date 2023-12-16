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

        NixpkgsOutOfDate.enable = false;

        NixpkgsOutOfDate2Weeks = {
          expr = ''(time() - flake_input_last_modified{input="nixpkgs"}) / (60*60*24) > 14'';
          annotations.description = "{{$labels.host}}: nixpkgs flake is older than two weeks";
        };

        SmartErrors.expr = lib.mkForce ''smart_device_health_ok{enabled!="Disabled", host!="build01"} != 1'';
      };
  };
}
