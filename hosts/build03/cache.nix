{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  host = "temp-cache.nix-community.org";

  uploadScript = pkgs.writeShellApplication {
    name = "upload-script";
    runtimeInputs = [
      config.nix.package
    ];
    text = ''
      exec \
        nix copy \
        --to "https://${host}/default.signing?compression=none" \
        --netrc-file "$TEMP_CACHE_NETRC_FILE" \
        "$OUT_PATHS"
    '';
  };
in
{
  imports = [
    "${inputs.snix-cache}/nix/module.nix"
    "${inputs.queued-build-hook}/module.nix"
  ];

  sops.secrets.temp-cache-key = { };
  sops.secrets.temp-cache-nginx-auth-file.owner = "nginx";
  sops.secrets.temp-cache-netrc-file.owner = "queued-build-hook";

  services.snix-cache = {
    enable = true;

    inherit host;

    caches.default = {
      maxBodySize = "50G";
      uploadPasswordFile = config.sops.secrets.temp-cache-nginx-auth-file.path;
      signing = {
        keyFile = config.sops.secrets.temp-cache-key.path;
        passwordFile = config.sops.secrets.temp-cache-nginx-auth-file.path;
        publicKey = "temp-cache.nix-community.org-1:RSXIfGjilfBsilDvj03/VnL/9qAxacBnb1YQvSdCoDc=";
      };
    };
  };

  systemd.services.snix-cache = {
    environment.PRIORITY = "50";
  };

  services.nginx.virtualHosts.${host} = { };

  systemd.services.async-nix-post-build-hook = {
    environment.TEMP_CACHE_NETRC_FILE = config.sops.secrets.temp-cache-netrc-file.path;
    serviceConfig.DynamicUser = lib.mkForce false;
  };

  users.users.queued-build-hook = {
    home = "/var/lib/async-nix-post-build-hook";
    createHome = true;
    isSystemUser = true;
    group = "queued-build-hook";
    extraGroups = [ "trusted" ];
  };
  users.groups.queued-build-hook = { };

  queued-build-hook = {
    enable = true;
    postBuildScript = lib.getExe uploadScript;
  };
}
