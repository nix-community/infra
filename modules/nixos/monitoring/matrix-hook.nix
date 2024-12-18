{
  config,
  inputs,
  pkgs,
  ...
}:
let
  matrixHook = pkgs.matrix-hook;
in
{
  age.secrets.nix-community-matrix-bot-token = {
    file = "${inputs.self}/secrets/nix-community-matrix-bot-token.age";
  };

  users.users.matrix-hook = {
    isSystemUser = true;
    group = "matrix-hook";
  };
  users.groups.matrix-hook = { };

  systemd.services.matrix-hook = {
    description = "Matrix Hook";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ config.systemd.targets.multi-user.name ];
    environment = {
      HTTP_ADDRESS = "localhost";
      HTTP_PORT = "9088";
      MX_HOMESERVER = "https://matrix-client.matrix.org";
      MX_ID = "@nix-community-matrix-bot:matrix.org";
      MX_ROOMID = "!cBybDCkeRlSWfuaFvn:numtide.com";
      MX_MSG_TEMPLATE = "${matrixHook}/message.html.tmpl";
    };
    serviceConfig = {
      Type = "simple";
      ExecStart = "${matrixHook}/bin/matrix-hook";
      EnvironmentFile = [ config.age.secrets.nix-community-matrix-bot-token.path ];
      Restart = "always";
      RestartSec = "10";
      User = "matrix-hook";
      Group = "matrix-hook";
    };
  };
}
