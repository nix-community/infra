let
  adisbladis = builtins.readFile ../users/keys/adisbladis;
  mic92 = builtins.readFile ../users/keys/mic92;
  ryantm = builtins.readFile ../users/keys/ryantm;
  zimbatm = builtins.readFile ../users/keys/zimbatm;
  zowoq = builtins.readFile ../users/keys/zowoq;

  users = [
    adisbladis
    mic92
    ryantm
    zimbatm
    zowoq
  ];

  inherit ((import ../modules/shared/known-hosts.nix).programs.ssh) knownHosts;

  build03 = knownHosts.build03.publicKey;
  build04 = knownHosts.build04.publicKey;
  darwin02 = knownHosts.darwin02.publicKey;
in
{
  "hercules-binary-caches.age".publicKeys = users ++ [
    build03
    build04
    darwin02
  ];
  "hercules-cluster-join-token.age".publicKeys = users ++ [
    build03
    build04
    darwin02
  ];
  "hercules-secrets.age".publicKeys = users ++ [
    build03
    build04
  ]; # hercules-secrets are only needed on linux
}
