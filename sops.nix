# https://github.com/TUM-DSE/doctor-cluster-config/blob/8c11c117e66af1cc205eb2094ab94e8a3317ff2e/sops.yaml.nix
let
  keys = builtins.fromJSON (builtins.readFile ./sops.json);
  admins = builtins.attrValues keys.admins;

  hosts =
    builtins.mapAttrs (_: v: v.publicKey)
      (import ./modules/shared/known-hosts.nix).programs.ssh.knownHosts;

  mapAttrsToList = f: attrs: map (name: f name attrs.${name}) (builtins.attrNames attrs);

  renderPermissions =
    attrs:
    mapAttrsToList (path: keys: {
      path_regex = "^${path}$";
      key_groups = [
        {
          age = keys ++ admins;
        }
      ];
    }) attrs;

  # This is the list of permissions per file. The admins have permissions for all files.
  sopsPermissions = {
    "secrets.yaml" = [ ];
    "terraform/secrets.yaml" = [ ];
  }
  // builtins.mapAttrs (_: value: (map (x: hosts.${x}) value)) {
    "modules/secrets/backup.yaml" = [
      "build02"
      "build03"
      "web02"
    ];
    "modules/secrets/community-builder.yaml" = [
      "build01"
      "build05"
      "darwin01"
    ];
    "modules/secrets/hercules-ci.yaml" = [
      "build03"
      "build04"
      "darwin02"
    ];
    "modules/secrets/rfc39_private_key.der" = [
      "build03"
    ];
  }
  // builtins.listToAttrs (
    mapAttrsToList (hostname: key: {
      name = "hosts/${hostname}/secrets.yaml";
      value = [ key ];
    }) hosts
  );
in
{
  creation_rules = renderPermissions sopsPermissions;
}
