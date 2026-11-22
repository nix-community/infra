{
  virtualisation.vmVariant.virtualisation = {
    diskImage = "./disk.qcow2";
    forwardPorts = [
      {
        from = "host";
        host.port = 31022;
        guest.port = 22;
      }
      {
        from = "host";
        host.port = 39273;
        guest.port = 9273;
      }
    ];
    sharedDirectories.secrets = {
      source = "/var/lib/vm-builder/secrets";
      target = "/mnt/secrets";
      type = "9p";
      readOnly = true;
    };
  };

  imports = [ ./configuration.nix ];
}
