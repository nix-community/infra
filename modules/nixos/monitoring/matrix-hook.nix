{ config, pkgs, ... }:
let
  matrixHook = pkgs.matrix-hook;
in
{
  sops.secrets.nix-community-matrix-bot-token = { };

  users.users.matrix-hook = {
    isSystemUser = true;
    group = "matrix-hook";
  };
  users.groups.matrix-hook = { };

  systemd.services.matrix-hook = {
    description = "Matrix Hook";
    after = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
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
      EnvironmentFile = [
        config.sops.secrets.nix-community-matrix-bot-token.path
      ];
      Restart = "always";
      RestartSec = "10";
      User = "matrix-hook";
      Group = "matrix-hook";
    };
  };
}
