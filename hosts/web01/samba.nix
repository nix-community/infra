{ config, pkgs, ... }:

let
  inherit (builtins) concatStringsSep;

  hostname = "u348918.your-storagebox.de";

in
{
  sops.secrets.hetzner-cifs-lemmy-pict-rs-creds = { };
  sops.secrets.hetzner-cifs-web01-pgbackrest = { };

  fileSystems =
    let
      cifsOpts = [
        "x-systemd.automount"
        "noauto"
        "x-systemd.idle-timeout=60"
        "x-systemd.device-timeout=5s"
        "x-systemd.mount-timeout=5s"
        "x-systemd.requires=network-online.target"
        "x-systemd.after=network-online.target"
      ];
    in
    {
      "/mnt/lemmy-pict-rs" = {
        device = "//${hostname}/u348918-sub1";
        fsType = "cifs";
        options = [
          "noperm"
          (concatStringsSep "," (cifsOpts ++ [
            "credentials=${config.sops.secrets.hetzner-cifs-lemmy-pict-rs-creds.path}"
          ]))
        ];
      };

      "/mnt/pgbackrest" = {
        device = "//${hostname}/u348918-sub2";
        fsType = "cifs";
        options = [
          (concatStringsSep "," (cifsOpts ++ [
            "uid=${toString config.users.users.postgres.uid}"
            "gid=${toString config.users.groups.postgres.gid}"
            "credentials=${config.sops.secrets.hetzner-cifs-web01-pgbackrest.path}"
          ]))
        ];
      };

    };

  environment.systemPackages = [ pkgs.cifs-utils ];
}
