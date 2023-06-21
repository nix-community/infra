{ config, ... }:
{
  # 100GB storagebox is under the build03 hetzner account

  sops.secrets.hetzner-build03-borgbackup-ssh = { };

  programs.ssh.knownHosts = {
    "hetzner-storage-box" = {
      hostNames = [ "[u348918.your-storagebox.de]:23" ];
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIICf9svRenC/PLKIL9nk6K/pxQgoiFC41wTNvoIncOxs";
    };
  };

  systemd.services.borgbackup-job-nixpkgs-update.serviceConfig.ReadWritePaths = [
    "/var/log/telegraf"
  ];

  services.borgbackup.jobs.nixpkgs-update = {
    paths = [
      "/var/log/nixpkgs-update"
    ];
    repo = "u348918@u348918.your-storagebox.de:/./nixpkgs-update";
    encryption.mode = "none";
    compression = "auto,zstd";
    startAt = "daily";
    environment.BORG_RSH = "ssh -oPort=23 -i ${config.sops.secrets.hetzner-build03-borgbackup-ssh.path}";
    preHook = ''
      set -x
    '';

    postHook = ''
      cat > /var/log/telegraf/borgbackup-nixpkgs-update <<EOF
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
