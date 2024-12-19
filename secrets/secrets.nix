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
  web02 = knownHosts.web02.publicKey;

  secrets = {
    grafana-client-secret = [ web02 ];
    hetzner-borgbackup-ssh = [
      build02
      build03
      web02
    ];
    nix-community-matrix-bot-token = [ web02 ];
    oauth2-proxy-key-file = [ web02 ];
  };
in
builtins.listToAttrs (
  map (secretName: {
    name = "${secretName}.age";
    value.publicKeys = secrets."${secretName}" ++ users;
  }) (builtins.attrNames secrets)
)
