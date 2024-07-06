{ config, lib, pkgs, ... }:
let
  supportsFs = fs: config.boot.supportedFilesystems.${fs} or false;

  ipv6DadCheck = pkgs.writeShellScript "ipv6-dad-check" ''
    ${pkgs.iproute2}/bin/ip --json addr | \
    ${pkgs.jq}/bin/jq -r 'map(.addr_info) | flatten(1) | map(select(.dadfailed == true)) | map(.local) | @text "ipv6_dad_failures count=\(length)i"'
  '';

  zfsChecks = lib.optional (supportsFs "zfs")
    (pkgs.writeScript "zpool-health" ''
      #!${pkgs.gawk}/bin/awk -f
      BEGIN {
        while ("${pkgs.zfs}/bin/zpool status" | getline) {
          if ($1 ~ /pool:/) { printf "zpool_status,name=%s ", $2 }
          if ($1 ~ /state:/) { printf " state=\"%s\",", $2 }
          if ($1 ~ /errors:/) {
              if (index($2, "No")) printf "errors=0i\n"; else printf "errors=%di\n", $2
          }
        }
      }
    '');
in
{
  imports = [
    ../../shared/telegraf.nix
  ];

  networking.firewall.allowedTCPPorts = [ 9273 ];

  systemd.services.telegraf.path = lib.optional (lib.any (m: m == "nvme") config.boot.initrd.availableKernelModules) pkgs.nvme-cli;

  security.wrappers.smartctl-telegraf = {
    owner = "telegraf";
    group = "telegraf";
    capabilities = "cap_sys_admin,cap_dac_override,cap_sys_rawio+ep";
    source = "${pkgs.smartmontools}/bin/smartctl";
  };

  # create dummy file to avoid telegraf errors
  systemd.tmpfiles.rules = [
    "f /var/log/telegraf/dummy 0444 root root - -"
  ];

  services.telegraf.extraConfig.inputs = {
    kernel_vmstat = { };
    nginx.urls = lib.mkIf config.services.nginx.enable [
      "http://localhost/nginx_status"
    ];
    smart = {
      path_smartctl = "/run/wrappers/bin/smartctl-telegraf";
    };
    file =
      [
        {
          data_format = "influx";
          file_tag = "name";
          files = [ "/var/log/telegraf/*" ];
        }
      ]
      ++ lib.optional (supportsFs "ext4") {
        name_override = "ext4_errors";
        files = [ "/sys/fs/ext4/*/errors_count" ];
        data_format = "value";
      };
    exec = [
      {
        commands =
          [ ipv6DadCheck ]
          ++ zfsChecks;
        data_format = "influx";
      }
    ];
    systemd_units = { };
    zfs = {
      poolMetrics = true;
    };
  };
}
