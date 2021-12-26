{
  # for mdraid 1.1
  boot.loader.grub.extraConfig = "insmod mdraid1x";
  services.telegraf.extraConfig.inputs.mdstat = {};
}
