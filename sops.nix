# https://github.com/TUM-DSE/doctor-cluster-config/blob/8c11c117e66af1cc205eb2094ab94e8a3317ff2e/sops.yaml.nix
let
  keys = builtins.fromJSON (builtins.readFile ./sops.json);
  admins = builtins.attrValues keys.admins;

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
  sopsPermissions =
    {
      "secrets.yaml" = [ ];
      "terraform/secrets.yaml" = [ ];
    }
    // builtins.mapAttrs (_: value: (map (x: keys.hosts.${x}) value)) { }
    // builtins.listToAttrs (
      mapAttrsToList (hostname: key: {
        name = "hosts/${hostname}/secrets.yaml";
        value = [ key ];
      }) keys.hosts
    );
in
{
  creation_rules = renderPermissions sopsPermissions;
}
