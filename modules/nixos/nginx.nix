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
          quic = true;

          extraConfig = ''
            quic_gso on;
            quic_retry on;
            add_header Alt-Svc 'h3=":$server_port"; ma=86400';
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
    networking.firewall.allowedUDPPorts = [ 443 ];

    services.nginx = {
      package = pkgs.nginxMainline;
      enableQuicBPF = true;

      appendConfig = ''
        pcre_jit on;
        worker_processes auto;
        worker_cpu_affinity auto;
      '';

      virtualHosts."${config.networking.hostName}.nix-community.org" = {
        default = true;
        locations."/".return = "404";
        # required for (quic && `worker_processes auto`), should only be set for one virtualHost
        reuseport = true;
      };

      # localhost is used by the nginx status page
      virtualHosts.localhost = {
        enableACME = false;
        forceSSL = false;
      };
    };
  };
}
