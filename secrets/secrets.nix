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

  web02 = knownHosts.web02.publicKey;

  secrets = {
    grafana-client-secret = [ web02 ];
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
