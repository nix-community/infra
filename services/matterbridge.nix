# A single instance of matterbridge
{ ... }: {
  sops.secrets.matterbridge.owner = "matterbridge";
  services.matterbridge.enable = true;
  services.matterbridge.configPath = "/run/keys/matterbridge.toml";
  # Allow to access /run/keys
  users.users.matterbridge.extraGroups = [ "keys" ];
}
