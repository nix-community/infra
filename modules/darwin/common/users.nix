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
    customer = {
      isAdminUser = true;
      isNormalUser = true;
      isTokenUser = true;
      openssh = {
        inherit authorizedKeys;
      };
      # admin user should always use the system default shell
      shell = "/bin/zsh";
    };
  };

  users.mutableUsers = false; # reinstall

  nix.configureBuildUsers = true; # reinstall

  nix.settings.trusted-users = [ "@admin" ];
}
