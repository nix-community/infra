{ config, lib, ... }:
{
  services.postgresql = {
    authentication = ''
      local terraform terraform peer map=tf_map
    '';

    identMap = lib.pipe config.users.users [
      (lib.filterAttrs (_: user: lib.elem "wheel" (user.extraGroups or [ ])))
      lib.attrNames
      (map (user: "tf_map ${user} terraform"))
      (lib.concatStringsSep "\n")
    ];

    ensureDatabases = [ "terraform" ];
    ensureUsers = [
      {
        name = "terraform";
        ensureDBOwnership = true;
      }
    ];
  };
}
