{ config, ... }:
{
  # 100GB storagebox is under the nix-community hetzner account

  sops.secrets.hetzner-borgbackup-ssh = { };

  systemd.services.borgbackup-job-nixpkgs-update = {
    after = [ "nixpkgs-update-delete-old-logs.service" ];
    serviceConfig.ReadWritePaths = [ "/var/log/telegraf" ];
  };

  services.borgbackup.jobs.nixpkgs-update = {
    paths = [ "/var/log/nixpkgs-update" ];
    repo = "u348918@u348918.your-storagebox.de:/./nixpkgs-update";
    encryption.mode = "none";
    compression = "auto,zstd";
    startAt = "daily";
    environment.BORG_RSH = "ssh -oPort=23 -i ${config.sops.secrets.hetzner-borgbackup-ssh.path}";
    preHook = ''
      set -x
    '';

    postHook = ''
      cat > /var/log/telegraf/borgbackup-job-nixpkgs-update.service <<EOF
      task,frequency=daily last_run=$(date +%s)i,state="$([[ $exitStatus == 0 ]] && echo ok || echo fail)"
      EOF
    '';

    prune.keep = {
      within = "1d"; # Keep all archives from the last day
      daily = 7;
      weekly = 4;
      monthly = 0;
    };
  };
}
