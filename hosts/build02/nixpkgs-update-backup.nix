{ config, inputs, ... }:
{
  # 100GB storagebox is attached to the build02 server

  imports = [
    inputs.self.nixosModules.backup
  ];

  nixCommunity.backup = [
    {
      name = "nixpkgs-update";
      after = [ config.systemd.services.nixpkgs-update-delete-old-logs.name ];
      paths = [ "/var/log/nixpkgs-update" ];
    }
  ];
}
