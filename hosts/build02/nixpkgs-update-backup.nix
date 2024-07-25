{ config, inputs, ... }:
{
  # 100GB storagebox is attached to the build02 server

  age.secrets.hetzner-borgbackup-ssh = {
    file = "${toString inputs.self}/secrets/hetzner-borgbackup-ssh.age";
  };

  systemd.services.borgbackup-job-nixpkgs-update = {
    after = [ "nixpkgs-update-delete-old-logs.service" ];
    serviceConfig.ReadWritePaths = [ "/var/log/telegraf" ];
  };

  services.borgbackup.jobs.nixpkgs-update = {
    paths = [ "/var/log/nixpkgs-update" ];
    repo = "u416406@u416406.your-storagebox.de:/./nixpkgs-update";
    encryption.mode = "none";
    compression = "auto,zstd";
    startAt = "daily";
    environment.BORG_RSH = "ssh -oPort=23 -i ${config.age.secrets.hetzner-borgbackup-ssh.path}";
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
