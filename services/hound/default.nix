{ pkgs, ... }:
{
  services.nginx.virtualHosts."search.nix-community.org" = {
    enableACME = true;
    forceSSL = true;
    locations = {
      "=/open_search.xml".alias = "${./open-search.xml}";
      "/".proxyPass = "http://127.0.0.1:6080/";
    };
  };

  services.hound = {
    enable = true;
    listen = "127.0.0.1:6080";
    config = builtins.readFile ./hound.json;
    package = pkgs.hound.overrideAttrs (x: {
      patches = [
        ./0001-Fail-to-start-if-any-repos-fail-to-index.patch
        ./0002-Custom-branch-specifier-PR-275.patch
        ./0003-PR-275-p1-Replace-master-in-the-default-base-URL-with-a-rev.patch
      ];
    });
  };

  systemd.services.hound.serviceConfig = {
    Restart = "always";
    RestartSec = 5;
  };
}
