{
  lib,
  config,
  pkgs,
  ...
}:
let
  userLib = import ./lib.nix { inherit lib; };
in
{
  users.users.mdaniels5757 = {
    openssh.authorizedKeys.keyFiles = [ ./keys/mdaniels5757 ];
    shell = pkgs.zsh;
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "trusted"
    ];
    # Keep pre-adminship accounts on community builders
    uid =
      if config.networking.hostName == "build01" then
        1075
      else if config.networking.hostName == "build05" then
        1074
      # Admins don't have seperate accounts on the Darwin machines:
      # See https://github.com/nix-community/infra/pull/2165#discussion_r2943863504
      # else if config.networking.hostName == "darwin01" then
      #   578
      else
        userLib.mkUid "mdan";
  };
}
