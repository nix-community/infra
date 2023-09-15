{ config, ... }:
let
  # on nix-darwin if user is removed the keys need to be removed manually from /etc/ssh/authorized_keys.d
  key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEmdo1x1QkRepZf7nSe+OdEWX+wOjkBLF70vX9F+xf68 builder";
in
{
  users.users.nix.openssh.authorizedKeys.keys = [
    # use nix-store for hydra which doesn't support ssh-ng
    ''restrict,command="${config.nix.package}/bin/nix-store --serve --write" ${key}''
  ];

  nix.settings.trusted-users = [ "nix" ];
}
