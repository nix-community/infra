with builtins;
let
  # Copied from <nixpkgs/lib>
  removeSuffix = suffix: str:
    let
      sufLen = stringLength suffix;
      sLen = stringLength str;
    in
    if
      sufLen <= sLen && suffix == substring (sLen - sufLen) sufLen str
    then
      substring 0 (sLen - sufLen) str
    else
      str;

  # Copied from <nixpkgs/lib>
  fileContents = file: removeSuffix "\n" (builtins.readFile file);

  readSecret = name: fileContents (./secrets + "/${name}");
in
mapAttrs
  (name: type: if type != "directory" then readSecret name else null)
  (readDir ./secrets)
