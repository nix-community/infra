{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
{
  options.services.nginx.virtualHosts = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule {
        config = {
          enableACME = lib.mkDefault true;
          forceSSL = lib.mkDefault true;
          kTLS = true;

          extraConfig = ''
            add_header X-Robots-Tag "none, noarchive, nosnippet";
          '';

          locations."= /robots.txt".alias = pkgs.writeText "robots.txt" ''
            User-agent: *
            Disallow: /
          '';
        };
      }
    );
  };

  imports = [ inputs.srvos.nixosModules.mixins-nginx ];

  config = {
    services.nginx = {
      appendConfig = ''
        pcre_jit on;
        worker_processes auto;
        worker_cpu_affinity auto;
      '';

      virtualHosts."${config.networking.hostName}.nix-community.org" = {
        default = true;
        locations."/".return = "404";
        reuseport = true; # should only be set for one virtualHost
      };

      # localhost is used by the nginx status page
      virtualHosts.localhost = {
        enableACME = false;
        forceSSL = false;
      };
    };
  };
}
