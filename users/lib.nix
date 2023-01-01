{ lib }:
let
  chrs = lib.listToAttrs (lib.imap (i: v: { name = v; value = i + 96; }) lib.lowerChars);
  ord = c: builtins.getAttr c chrs;
in
{
  # Make a unique UID from a 4-char identifier
  mkUid = id:
    let
      chars = lib.stringToCharacters (builtins.substring 0 4 id);
      n = builtins.map (c: lib.mod (ord c) 10) chars;
      s = builtins.concatStringsSep "" (builtins.map builtins.toString n);
    in
    assert builtins.stringLength id >= 4;
    assert builtins.length chars == 4;
    1000 + lib.toInt s;
}
