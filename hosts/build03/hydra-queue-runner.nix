{ config, inputs, ... }:
let
  secret = {
    owner = "hydra-queue-runner";
    sopsFile = "${inputs.self}/modules/secrets/hydra-queue-builder.yaml";
  };
in
{
  imports = [
    (import "${inputs.hydra}/nixos-modules/queue-runner-module.nix")
  ];

  #services.telegraf.extraConfig.inputs.prometheus.urls = [
  #  "http://localhost:9198/metrics" # queue runner
  #];

  sops.secrets = {
    hydra-queue-builder-token-build03 = secret;
    hydra-queue-builder-token-build04 = secret;
    hydra-queue-builder-token-darwin02 = secret;
  };

  services.hydra-queue-runner-dev = {
    enable = true;
    settings = {
      maxUnsupportedTimeInS = 10800;
      queueTriggerTimerInS = 300;
      useSubstitutes = true;
      tokenPaths = [
        config.sops.secrets.hydra-queue-builder-token-build03.path
        config.sops.secrets.hydra-queue-builder-token-build04.path
        config.sops.secrets.hydra-queue-builder-token-darwin02.path
      ];
    };
    rest.port = 9090;
  };

  services.nginx.virtualHosts."queue-runner.hydra.nix-community.org" = {
    locations."/".extraConfig = ''
      # This is necessary so that grpc connections do not get closed early
      # see https://stackoverflow.com/a/67805465
      client_body_timeout 31536000s;
      client_max_body_size 0;
      grpc_pass grpc://[::1]:${toString config.services.hydra-queue-runner-dev.grpc.port};
      grpc_read_timeout 31536000s; # 1 year in seconds
      grpc_send_timeout 31536000s; # 1 year in seconds
      grpc_socket_keepalive on;
      # Builders reuse one long-lived HTTP/2 channel for many RPCs. The
      # default keepalive_requests (1000) makes nginx GOAWAY mid-stream,
      # cancelling in-flight RPCs and aborting builds.
      keepalive_requests 1000000;
      keepalive_timeout 600s;
      grpc_set_header Host $host;
      grpc_set_header X-Real-IP $remote_addr;
      grpc_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      grpc_set_header X-Forwarded-Proto $scheme;
    '';
  };
}
