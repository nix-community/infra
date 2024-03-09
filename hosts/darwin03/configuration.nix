{ inputs, ... }:

{
  imports = [
    inputs.self.darwinModules.common
    inputs.self.darwinModules.builder
    inputs.self.darwinModules.remote-builder
  ];

  # on nix-darwin if user is removed the keys need to be removed manually from /etc/ssh/authorized_keys.d
  nixCommunity.remote-builder.key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKq4Jo8KcZEo3dcSBxFyaZA9Y8qWBLbOA/6aF6oqNYDS darwin-community-builder";

  nix.settings.sandbox = "relaxed";
  nix.settings.extra-platforms = [ "x86_64-darwin" ];

  # disable nixos-tests
  nix.settings.system-features = [ "big-parallel" ];

  networking.hostName = "darwin03";

  system.stateVersion = 4;
}
