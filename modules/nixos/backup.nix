{
  config,
  lib,
  inputs,
  ...
}:
{
  options.nixCommunity.backup = lib.mkOption {
    type = lib.types.listOf (
      lib.types.submodule {
        options = {
          name = lib.mkOption {
            type = lib.types.str;
          };
          after = lib.mkOption {
            type = lib.types.listOf lib.types.str;
          };
          paths = lib.mkOption {
            type = lib.types.listOf lib.types.str;
          };
        };
      }
    );

  };
  config = {
    # 100GB storagebox is attached to the build02 server

    age.secrets.hetzner-borgbackup-ssh = {
      file = "${inputs.self}/secrets/hetzner-borgbackup-ssh.age";
    };

    programs.ssh.knownHosts.hetzner-storage-box = {
      hostNames = [ "[u416406.your-storagebox.de]:23" ];
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIICf9svRenC/PLKIL9nk6K/pxQgoiFC41wTNvoIncOxs";
    };

    services.borgbackup.jobs = builtins.listToAttrs (
      builtins.map (backup: {
        inherit (backup) name;
        value = {
          inherit (backup) paths;
          repo = "u416406@u416406.your-storagebox.de:/./${config.networking.hostName}-${backup.name}";
          encryption.mode = "none";
          compression = "auto,zstd";
          startAt = "daily";
          environment.BORG_RSH = "ssh -oPort=23 -i ${config.age.secrets.hetzner-borgbackup-ssh.path}";
          preHook = "set -x";
          postHook = ''
            cat > /var/log/telegraf/borgbackup-job-${backup.name}.service <<EOF
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
      }) config.nixCommunity.backup
    );

    systemd.services = builtins.listToAttrs (
      builtins.map (backup: {
        name = "borgbackup-job-${backup.name}";
        value = {
          inherit (backup) after;
          serviceConfig.ReadWritePaths = [ "/var/log/telegraf" ];
        };
      }) config.nixCommunity.backup
    );
  };
}
