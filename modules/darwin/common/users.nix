{ inputs, pkgs, ... }:
let
  authorizedKeys = {
    keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDPVjRBomWFJNNkZb0g5ymLmc3pdRddIScitmJ9yC+ap" # deployment
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

  nix.settings.trusted-users = [ "@admin" ];
}
