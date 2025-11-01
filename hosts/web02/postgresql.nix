{
  config,
  inputs,
  pkgs,
  ...
}:
{
  imports = [
    inputs.self.nixosModules.backup
  ];

  services.postgresqlBackup = {
    enable = true;
    compression = "none";
    startAt = "daily";
  };

  nixCommunity.backup = [
    {
      name = "postgresql";
      after = [ config.systemd.services.postgresqlBackup.name ];
      paths = [ config.services.postgresqlBackup.location ];
      startAt = "daily";
    }
  ];

  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_18;
  };
}
