{
  config,
  inputs,
  lib,
  ...
}:
{
  imports = [ "${inputs.self}/modules/queue-runner/hydra-queue-runner-v2.nix" ];

  sops.secrets.queue-runner-server-key.owner = "nginx";

  nixCommunity.hydra-queue-runner-v2 = {
    enable = true;
    settings = {
      queueTriggerTimerInS = 300;
      useSubstitutes = true;
    };
    rest.port = 9090;
  };

  services.hydra = {
    extraConfig = lib.mkAfter ''
      queue_runner_endpoint = http://localhost:9090
    '';
  };

  systemd.services.hydra-queue-runner.enable = false;

  services.nginx.virtualHosts."queue-runner.hydra.nix-community.org" = {
    # disable defaults
    enableACME = false;
    forceSSL = false;

    extraConfig = ''
      client_max_body_size 5120M;
      ssl_client_certificate ${./ca.crt};
      ssl_verify_depth 2;
      ssl_verify_client on;
    '';

    sslCertificate = "${./server.crt}";
    sslCertificateKey = config.sops.secrets.queue-runner-server-key.path;
    onlySSL = true;

    locations."/".extraConfig = ''
      # This is necessary so that grpc connections do not get closed early
      # see https://stackoverflow.com/a/67805465
      client_body_timeout 31536000s;
      grpc_pass grpc://[::1]:50051;
      grpc_read_timeout 31536000s; # 1 year in seconds
      grpc_send_timeout 31536000s; # 1 year in seconds
      grpc_socket_keepalive on;
      grpc_set_header Host $host;
      grpc_set_header X-Real-IP $remote_addr;
      grpc_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      grpc_set_header X-Forwarded-Proto $scheme;
      grpc_set_header X-Client-DN $ssl_client_s_dn;
      grpc_set_header X-Client-Cert $ssl_client_escaped_cert;
    '';
  };
}
