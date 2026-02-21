{ config, ... }:
{
  # 100GB storagebox is attached to the build02 server

  sops.secrets.build02-borgbackup-ssh = { };

  programs.ssh.knownHosts.build02-hetzner-storage-box = {
    hostNames = [ "[u416406.your-storagebox.de]:23" ];
    publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIICf9svRenC/PLKIL9nk6K/pxQgoiFC41wTNvoIncOxs";
  };

  services.borgbackup.jobs.nixpkgs-update = {
    paths = [ "/var/log/nixpkgs-update" ];
    repo = "u416406@u416406.your-storagebox.de:/./build02-nixpkgs-update";
    encryption.mode = "none";
    compression = "auto,zstd";
    startAt = "hourly";
    environment.BORG_RSH = "ssh -oPort=23 -i ${config.sops.secrets.build02-borgbackup-ssh.path}";
    preHook = ''
      set -x
    '';

    postHook = ''
      cat > /var/log/telegraf/borgbackup-job-nixpkgs-update.service <<EOF
      task,frequency=hourly last_run=$(date +%s)i,state="$([[ $exitStatus == 0 ]] && echo ok || echo fail)"
      EOF
    '';

    prune.keep = {
      within = "1d"; # Keep all archives from the last day
      daily = 7;
      weekly = 4;
      monthly = 0;
    };
  };

  systemd.services.borgbackup-job-nixpkgs-update = {
    after = [ config.systemd.services.nixpkgs-update-delete-old-logs.name ];
    serviceConfig.ReadWritePaths = [ "/var/log/telegraf" ];
    serviceConfig.Restart = "on-failure";
  };
}
