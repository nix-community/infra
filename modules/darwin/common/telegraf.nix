{ pkgs, ... }:
{
  imports = [
    ../../shared/telegraf.nix
  ];

  services.telegraf = {
    enable = true;
    extraConfig = {
      agent.interval = "60s";
      inputs = {
        smart.path_smartctl = "${pkgs.smartmontools}/bin/smartctl";
        system = { };
        mem = { };
        swap = { };
        disk.tagdrop = {
          fstype = [ "tmpfs" "ramfs" "devtmpfs" "devfs" "iso9660" "overlay" "aufs" "squashfs" ];
          device = [ "rpc_pipefs" "lxcfs" "nsfs" "borgfs" ];
        };
        diskio = { };
        internal = { };
      };
      outputs.prometheus_client = {
        listen = ":9273";
        metric_version = 2;
      };
    };
  };
}
