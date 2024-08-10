let
  users = map (name: builtins.readFile ../users/keys/${name}) userNames;

  userNames = [
    "adisbladis"
    "mic92"
    "ryantm"
    "zimbatm"
    "zowoq"
  ];

  inherit ((import ../modules/shared/known-hosts.nix).programs.ssh) knownHosts;

  build02 = knownHosts.build02.publicKey;
  build03 = knownHosts.build03.publicKey;
  build04 = knownHosts.build04.publicKey;
  darwin02 = knownHosts.darwin02.publicKey;

  secrets = {
    hercules-binary-caches = [
      build03
      build04
      darwin02
    ];
    hercules-cluster-join-token = [
      build03
      build04
      darwin02
    ];
    # hercules-secrets are only needed on linux
    hercules-secrets = [
      build03
      build04
    ];
    hetzner-borgbackup-ssh = [
      build02
      build03
    ];
  };
in
builtins.listToAttrs (
  map (secretName: {
    name = "${secretName}.age";
    value.publicKeys = secrets."${secretName}" ++ users;
  }) (builtins.attrNames secrets)
)
