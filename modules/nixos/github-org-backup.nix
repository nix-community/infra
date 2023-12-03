{ config, pkgs, ... }:
{
  # upstream docs show how to restore these backups
  # https://github.com/gabrie30/ghorg/blob/92965c8b25ca423223888e1138d175bfc2f4b39b/README.md#creating-backups
  systemd.services.github-org-backup = {
    environment.HOME = "/var/lib/github-org-backup";
    path = [ pkgs.git pkgs.ghorg ];
    # exclude nix, nixpkgs
    script = ''
      ghorg clone nix-community \
        --backup \
        --clone-wiki \
        --concurrency 2 \
        --exclude-match-regex '^(nix|nixpkgs)$' \
        --no-token \
        --path /var/lib/github-org-backup \
        --prune \
        --prune-no-confirm
    '';
    startAt = "daily";
    serviceConfig.Type = "oneshot";
  };

  sops.secrets.hetzner-borgbackup-ssh = { };

  systemd.services.borgbackup-job-github-org = {
    after = [ "github-org-backup.service" ];
    serviceConfig.ReadWritePaths = [
      "/var/log/telegraf"
    ];
  };

  services.borgbackup.jobs.github-org = {
    paths = [
      "/var/lib/github-org-backup"
    ];
    repo = "u348918@u348918.your-storagebox.de:/./github-org";
    encryption.mode = "none";
    compression = "auto,zstd";
    startAt = "daily";
    environment.BORG_RSH = "ssh -oPort=23 -i ${config.sops.secrets.hetzner-borgbackup-ssh.path}";
    preHook = ''
      set -x
    '';

    postHook = ''
      cat > /var/log/telegraf/borgbackup-job-github-org.service <<EOF
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
