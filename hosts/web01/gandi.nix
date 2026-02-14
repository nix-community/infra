# This is the configuration required to run NixOS on GandiCloud.
{
  config,
  lib,
  modulesPath,
  ...
}:
{
  imports = [ (modulesPath + "/virtualisation/openstack-config.nix") ];
  config = {
    boot.initrd.kernelModules = [
      "xen-blkfront"
      "xen-tpmfront"
      "xen-kbdfront"
      "xen-fbfront"
      "xen-netfront"
      "xen-pcifront"
      "xen-scsifront"
    ];

    # Show debug kernel message on boot then reduce loglevel once booted
    boot.consoleLogLevel = 7;
    boot.kernel.sysctl."kernel.printk" = "4 4 1 7";

    # For "openstack console log show"
    boot.kernelParams = [ "console=ttyS0" ];
    systemd.services."serial-getty@ttyS0" = {
      enable = true;
      wantedBy = [ config.systemd.targets.multi-user.name ];
      serviceConfig.Restart = "always";
    };

    # The device exposed by Xen
    boot.loader.grub.device = lib.mkForce "/dev/xvda";

    # This is to get a prompt via the "openstack console url show" command
    systemd.services."getty@tty1" = {
      enable = lib.mkForce true;
      wantedBy = [ config.systemd.targets.multi-user.name ];
      serviceConfig.Restart = "always";
    };

    # This is required to get an IPv6 address on our infrastructure
    networking.tempAddresses = "disabled";

    system.stateVersion = "24.11";
  };
}
