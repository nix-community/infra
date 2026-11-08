{ config, inputs, ... }:
{
  imports = [
    (import "${inputs.hydra}/nixos-modules/ad-hoc-module.nix")
  ];

  services.hydra-ad-hoc-dev = {
    enable = true;
  };

  users.users.nixbot.extraGroups = [
    config.systemd.sockets.hydra-ad-hoc-dev.socketConfig.SocketGroup
  ];
  services.nixbot.buildStore.url = "unix://${config.services.hydra-ad-hoc-dev.socketPath}";
}
