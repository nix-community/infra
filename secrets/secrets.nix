let
  adisbladis = builtins.readFile ../users/keys/adisbladis;
  mic92 = builtins.readFile ../users/keys/mic92;
  ryantm = builtins.readFile ../users/keys/ryantm;
  zimbatm = builtins.readFile ../users/keys/zimbatm;
  zowoq = builtins.readFile ../users/keys/zowoq;

  users = [ adisbladis mic92 ryantm zimbatm zowoq ];

  inherit ((import ../modules/shared/known-hosts.nix).programs.ssh) knownHosts;

  darwin02 = knownHosts.darwin02.publicKey;
  darwin03 = knownHosts.darwin03.publicKey;
in
{
  "binary-caches.age".publicKeys = users ++ [ darwin02 darwin03 ];
  "cluster-join-token.age".publicKeys = users ++ [ darwin02 darwin03 ];
}
