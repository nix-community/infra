{ lib }:

let
  chrs = lib.listToAttrs (lib.imap (i: v: {name=v; value=i + 96;}) lib.lowerChars);
  ord = c: builtins.getAttr c chrs;

in {
  # Make a unique UID from a 4-char identifier
  mkUid = id: let  # TODO: Assert length
    chars = lib.stringToCharacters id;
    n = builtins.map (c: lib.mod (ord c) 10) chars;
    s = builtins.concatStringsSep "" (builtins.map (i: builtins.toString i) n);

  in
    assert lib.length chars == 4;
    1000 + lib.toInt s;
}
