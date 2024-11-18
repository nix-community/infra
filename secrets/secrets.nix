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

  build01 = knownHosts.build01.publicKey;
  build02 = knownHosts.build02.publicKey;
  build03 = knownHosts.build03.publicKey;
  build04 = knownHosts.build04.publicKey;
  darwin01 = knownHosts.darwin01.publicKey;
  darwin02 = knownHosts.darwin02.publicKey;
  web02 = knownHosts.web02.publicKey;

  secrets = {
    # fine-grained, no permissions github token, expires 2025-10-29
    # from `nix-community-buildbot` (user account, not the github app)
    community-builder-nix-access-tokens = [
      build01
      darwin01
    ];
    grafana-client-secret = [ web02 ];
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
      web02
    ];
    nginx-basic-auth-file = [ web02 ];
    nix-community-matrix-bot-token = [ web02 ];
  };
in
builtins.listToAttrs (
  map (secretName: {
    name = "${secretName}.age";
    value.publicKeys = secrets."${secretName}" ++ users;
  }) (builtins.attrNames secrets)
)
