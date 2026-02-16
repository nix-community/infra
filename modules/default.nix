{ inputs, lib, ... }:
# https://github.com/numtide/blueprint/blob/19df68dde6fe1aeaf15c747b16708136b40d2ab7/lib/default.nix
let
  importDir =
    path: fn:
    let
      entries = builtins.readDir path;

      onlyDirs = lib.filterAttrs (
        name: type:
        type == "directory"
        &&
          # filter `common` dir
          (name != "common")
      ) entries;
      dirPaths = lib.mapAttrs (name: type: {
        path = path + "/${name}";
        inherit type;
      }) onlyDirs;

      nixPaths = removeAttrs (lib.mapAttrs' (
        name: type:
        let
          nixName = builtins.match "(.*)\\.nix" name;
        in
        {
          name = if type == "directory" || nixName == null then "__junk" else (builtins.head nixName);
          value = {
            path = path + "/${name}";
            inherit type;
          };
        }
      ) entries) [ "__junk" ];

      combined = dirPaths // nixPaths;
    in
    lib.optionalAttrs (builtins.pathExists path) (fn combined);

  modules = path: importDir path (lib.mapAttrs (_name: { path, ... }: path));
in
{
  flake = {
    darwinModules = modules "${inputs.self}/modules/darwin";
    nixosModules = modules "${inputs.self}/modules/nixos";
  };
}
