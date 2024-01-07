{ config, pkgs, ... }:
let
  # on nix-darwin if user is removed the keys need to be removed manually from /etc/ssh/authorized_keys.d
  key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEmdo1x1QkRepZf7nSe+OdEWX+wOjkBLF70vX9F+xf68 builder";

  # https://discourse.nixos.org/t/wrapper-to-restrict-builder-access-through-ssh-worth-upstreaming/25834
  nix-ssh-wrapper = pkgs.writeShellScript "nix-ssh-wrapper" ''
    case $SSH_ORIGINAL_COMMAND in
      "nix-daemon --stdio")
        exec ${config.nix.package}/bin/nix-daemon --stdio
        ;;
      "nix-store --serve --write")
        exec ${config.nix.package}/bin/nix-store --serve --write
        ;;
      *)
        echo "Access only allowed for using the nix remote builder" 1>&2
        exit
    esac
  '';
in
{
  users.users.nix.openssh.authorizedKeys.keys = [
    # use nix-store for hydra which doesn't support ssh-ng
    ''restrict,command="${nix-ssh-wrapper}" ${key}''
  ];

  nix.settings.trusted-users = [ "nix" ];
}
