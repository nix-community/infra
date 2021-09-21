{ pkgs, lib, config, ... }:
let
  userLib = import ../users/lib.nix { inherit lib; };
  sources = import ../nix/sources.nix;

  marvinNixpkgs = (import (sources.marvin-mk2.outPath + "/definitions.nix") { }).pkgs;

  marvin-mk2 = marvinNixpkgs.python3.pkgs.buildPythonApplication rec {
    pname = "marvin-mk2";
    version = "rolling";
    src = sources.marvin-mk2;

    propagatedBuildInputs = with marvinNixpkgs.python3.pkgs; [
      aiohttp
      gidgethub
    ];
  };
in
{
  services.nginx.virtualHosts."marvin-2k.nix-community.org" = {
    enableACME = true;
    forceSSL = true;
    locations = {
      "/".proxyPass = "http://127.0.0.1:3001/";
    };
  };

  # FIXME: use the above host instead
  networking.firewall.allowedTCPPorts = [ 3001 ];

  users.groups.marvin-mk2 = { };
  users.users.marvin-mk2 = {
    useDefaultShell = true;
    isSystemUser = true;
    uid = userLib.mkUid "mmkt";
    group = "marvin-mk2";
  };

  systemd.services.marvin-mk2 = {
    description = "marvin-mk2 service";
    enable = true;
    path = [
      marvin-mk2
    ];
    environment.BOT_NAME = "marvin-mk2";
    environment.PORT = "3001";
    environment.GH_PRIVATE_KEY_FILE = "/var/lib/marvin-mk2/marvin-mk2-key.pem";
    environment.GH_APP_ID_FILE = "/var/lib/marvin-mk2/marvin_mk2_id.txt";
    environment.WEBHOOK_SECRET_FILE = "/var/lib/marvin-mk2/marvin-mk2-webhook-secret.txt";

    # Disable python stdout buffering to avoid log messages getting stuck in
    # the buffer. Should probably use a proper logging framework instead.
    environment.PYTHONUNBUFFERED = "1";

    serviceConfig = {
      User = "marvin-mk2";
      Group = "marvin-mk2";
      WorkingDirectory = "/var/lib/marvin-mk2";
      StateDirectory = "marvin-mk2";
      StateDirectoryMode = "700";
      CacheDirectory = "marvin-mk2";
      CacheDirectoryMode = "700";
      LogsDirectory = "marvin-mk2";
      LogsDirectoryMode = "755";
      StandardOutput = "journal";
    };

    script = ''
      marvin
    '';

    wantedBy = [ "multi-user.target" ];
  };
}
