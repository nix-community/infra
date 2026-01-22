{
  config,
  inputs,
  pkgs,
  ...
}:
{
  # 100GB storagebox is attached to the build02 server

  imports = [
    inputs.self.nixosModules.backup
  ];

  # upstream docs show how to restore these backups
  # https://github.com/gabrie30/ghorg/blob/92965c8b25ca423223888e1138d175bfc2f4b39b/README.md#creating-backups
  systemd.services.github-org-backup = {
    environment.HOME = "/var/lib/github-org-backup";
    path = [
      pkgs.git
      pkgs.ghorg
    ];
    # exclude nix, nixpkgs
    script = ''
      ghorg clone nix-community \
        --backup \
        --clone-wiki \
        --concurrency 2 \
        --exclude-match-regex '^(nix|nixpkgs|nix4vscode)$' \
        --no-token \
        --path /var/lib/github-org-backup \
        --prune \
        --prune-no-confirm
    '';
    startAt = "daily";
    serviceConfig.Type = "oneshot";
  };

  nixCommunity.backup = [
    {
      name = "github-org";
      after = [ config.systemd.services.github-org-backup.name ];
      paths = [ "/var/lib/github-org-backup" ];
      startAt = "daily";
    }
  ];
}
