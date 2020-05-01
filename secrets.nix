with builtins;
let
  readSecret = name: readFile (./secrets + "/${name}");
in
mapAttrs
  (name: type: if type != "directory" then readSecret name else null)
  (readDir ./secrets)
