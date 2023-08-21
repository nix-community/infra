{ config, pkgs, ... }:
let
  matrixHook = pkgs.buildGoModule rec {
    pname = "matrix-hook";
    version = "2e2770e685ca57e111b9dd2dc178cc6984404a25";
    src = pkgs.fetchFromGitHub {
      owner = "pinpox";
      repo = "matrix-hook";
      rev = version;
      hash = "sha256-G5pq9sIz94V2uTYBcuHJsqD2/pMtxhWkAO8B0FncLbE=";
    };
    vendorHash = "sha256-185Wz9IpJRBmunl+KGj/iy37YeszbT3UYzyk9V994oQ=";
    postInstall = ''
      install message.html.tmpl -Dt $out
    '';
  };
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
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    environment = {
      HTTP_ADDRESS = "localhost";
      HTTP_PORT = "9088";
      MX_HOMESERVER = "https://matrix-client.matrix.org";
      MX_ID = "@nix-community-matrix-bot:matrix.org";
      MX_ROOMID = "!cBybDCkeRlSWfuaFvn:numtide.com";
      MX_MSG_TEMPLATE = "${./message.html.tmpl}";
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
