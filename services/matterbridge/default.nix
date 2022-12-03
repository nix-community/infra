# A single instance of matterbridge
{ config, ... }: {
  sops.secrets.matterbridge.owner = "matterbridge";
  services.matterbridge.enable = true;
  services.matterbridge.configPath = config.sops.secrets.matterbridge.path;
  # Allow to access /run/keys
  users.users.matterbridge.extraGroups = [ "keys" ];
}
