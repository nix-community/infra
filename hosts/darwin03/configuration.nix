{ inputs, ... }:

{
  imports = [
    inputs.self.darwinModules.common
    inputs.self.darwinModules.builder
    inputs.self.darwinModules.hercules-ci
  ];

  nix.settings.sandbox = "relaxed";
  nix.settings.extra-platforms = [ "x86_64-darwin" ];

  # disable nixos-tests
  nix.settings.system-features = [ "big-parallel" ];

  networking.hostName = "darwin03";

  system.stateVersion = 4;

  # TODO: refactor this to share /users with nixos
  # keys are copied, not symlinked
  users.users.hetzner.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOG/9rsFqC2tg+W5YZxthW5xhUJEfZ8ShqkRtVe+A6+u" # hercules-ssh-deploy
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKbBp2dH2X3dcU1zh+xW3ZsdYROKpJd3n13ssOP092qE" # mic92
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOuiDoBOxgyer8vGcfAIbE6TC4n4jo8lhG9l01iJ0bZz" # zimbatm
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFbCYwWByGE46XHH4Q0vZgQ5sOUgbH50M8KO2xhBC4m/" # zowoq
  ];
}
