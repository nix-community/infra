{
  virtualisation.vmVariant.virtualisation = {
    diskImage = null;
    netMountBoot = true;
    netMountNixStore = true;
  };

  imports = [ ./configuration.nix ];
}
