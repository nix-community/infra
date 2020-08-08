{ ... }: {
  services.matterbridge.enable = true;
  services.matterbridge.configPath = "/run/keys/matterbridge.toml";
}
