{ inputs, pkgs, ... }:
let
  authorizedKeys = {
    keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDPVjRBomWFJNNkZb0g5ymLmc3pdRddIScitmJ9yC+ap" # deployment
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPoUUwDIYFzuUk8pxzekyVhqdYhShAtRAG+K3AJMMdjz" # effects-deployment
    ];
    keyFiles = pkgs.lib.filesystem.listFilesRecursive "${inputs.self}/users/keys";
  };
in
{
  # TODO: refactor this to share /users with nixos
  users.users = {
    customer.openssh = {
      inherit authorizedKeys;
    };
  };
}
