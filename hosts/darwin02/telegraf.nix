{ pkgs, ... }:
{
  services.telegraf = {
    enable = true;
    # can switch back to nixpkgs after > 1.26.3
    package = pkgs.buildGoModule rec {
      pname = "telegraf";
      version = "1.26.3";
      subPackages = [ "cmd/telegraf" ];
      src = pkgs.fetchFromGitHub {
        owner = "influxdata";
        repo = "telegraf";
        rev = "ebe346103ebfd96b63cdbd2f3f36b2258746c160";
        hash = "sha256-j6VWbF6B7+TQlLNdQMwN7r4kOUGQi5c/PigNZhJA2Zk=";
      };
      vendorHash = "sha256-4WmXEa42zyeRGcdXe4REILYNMZZ83FVzDDaKFMnx37Y=";
      proxyVendor = true;
      ldflags = [ "-s" "-w" "-X=github.com/influxdata/telegraf/internal.Commit=${src.rev}" "-X=github.com/influxdata/telegraf/internal.Version=${version}" ];
    };
    extraConfig = {
      agent.interval = "60s";
      inputs = {
        prometheus.metric_version = 2;
        system = { };
        mem = { };
        disk.tagdrop = {
          fstype = [ "tmpfs" "ramfs" "devtmpfs" "devfs" "iso9660" "overlay" "aufs" "squashfs" ];
          device = [ "rpc_pipefs" "lxcfs" "nsfs" "borgfs" ];
        };
        diskio = { };
      };
      outputs.prometheus_client = {
        listen = ":9273";
        metric_version = 2;
      };
    };
  };
}
