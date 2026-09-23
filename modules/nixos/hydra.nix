{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
{
  disabledModules = [
    "services/continuous-integration/hydra/default.nix"
  ];

  imports = [
    (import "${inputs.hydra}/nixos-modules/ad-hoc-module.nix")
    (import "${inputs.hydra}/nixos-modules/queue-runner-module.nix")
    (import "${inputs.hydra}/nixos-modules/web-app.nix")
    (import "${inputs.hydra}/nixos-modules/ws-server-module.nix")
  ];

  systemd.services.hydra-init.enableStrictShellChecks = false;

  sops.secrets.hydra-admin-password.owner = "hydra";
  sops.secrets.hydra-users.owner = "hydra";

  nix.settings.extra-allowed-users = [
    "hydra-www"
    "hydra"
  ];
  nix.settings.keep-outputs = lib.mkForce false;

  nix.settings.allowed-uris = [
    "git+https:"
    "github:"
    "gitlab:"
    "https:"
    "sourcehut:"
  ];

  # delete build logs older than 30 days
  systemd.services.hydra-delete-old-logs = {
    startAt = "Sun 05:45";
    serviceConfig.ExecStart = "${pkgs.findutils}/bin/find /var/lib/hydra/build-logs -type f -mtime +30 -delete";
  };

  # not currently needed, hydra-notify would need to be enabled for declarative jobsets
  systemd.services = {
    hydra-evaluator-check-space.enable = false;
    hydra-queue-runner-check-space.enable = false;
    hydra-notify.enable = false;
    hydra-send-stats.enable = false;
  };

  sops.secrets.hydra-queue-runner-tokens = { };

  services.hydra-ad-hoc-dev = {
    enable = true;
  };

  services.hydra-queue-runner-dev = {
    enable = true;
    settings = {
      queueTriggerTimerInS = 300;
      useSubstitutes = true;
      tokenPaths = [ config.sops.secrets.hydra-queue-runner-tokens.path ];
    };
    rest.port = 9090;
  };

  services.hydra-ws-dev = {
    enable = true;
  };

  services.hydra-dev = {
    enable = true;
    hydraURL = "https://hydra.nix-community.org";
    notificationSender = "hydra@hydra.nix-community.org";
    port = 3000;
    useSubstitutes = true;
    evaluatorSettings = {
      max_concurrent_evals = 2;
    };
    extraConfig = ''
      evaluator_max_memory_size = 4096
      evaluator_workers = 8
      max_output_size = ${toString (8 * 1024 * 1024 * 1024)}

      github_client_id = Ov23ligaoPhIyuYCJ1pp
      github_client_secret_file = ${config.sops.secrets.hydra-github-client-secret.path}

      queue_runner_endpoint = http://localhost:${toString config.services.hydra-queue-runner-dev.rest.port}
      ws_endpoint = ws://localhost:${toString config.services.hydra-ws-dev.bind.port}
    '';
  };

  sops.secrets.hydra-github-client-secret = {
    owner = "hydra-www";
    group = "hydra";
  };

  services.nginx.virtualHosts."hydra.nix-community.org" = {
    locations."/".proxyPass = "http://localhost:${toString config.services.hydra-dev.port}";
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

  systemd.services.hydra-post-init = {
    serviceConfig = {
      Type = "oneshot";
      TimeoutStartSec = "60";
    };
    wantedBy = [ config.systemd.targets.multi-user.name ];
    after = [ config.systemd.services.hydra-server.name ];
    requires = [ config.systemd.services.hydra-server.name ];
    environment = {
      inherit (config.systemd.services.hydra-init.environment) HYDRA_DATABASE_URL;
    };
    path = [
      config.services.hydra-dev.package
    ];
    script =
      let
        # Create user accounts, github or hydra, format:
        # github;email;$role;;
        # hydra;user;$role;password-hash;
        # Password hash is computed by applying sha1 to the password.
        hydra-github-users = pkgs.writeText "hydra-github-users" ''
          github;adisbladis@gmail.com;admin;;
          github;mdaniels5757@gmail.com;admin;;
          github;zimbatm@zimbatm.com;admin;;
          github;zowoq.gh@gmail.com;admin;;
          github;me@linj.tech;restart-jobs;;
        '';
      in
      ''
        set -e
        users=("${config.sops.secrets.hydra-users.path}" "${hydra-github-users}")
        for f in "''${users[@]}"; do
          while IFS=';' read -r type user role passwordhash; do
            opts=("$user" "--role" "$role" "--type" "$type")
            if [[ -n "$passwordhash" ]]; then
              opts+=("--password-hash" "$passwordhash")
            fi
            hydra-create-user "''${opts[@]}"
          done < "$f"
        done
      '';
  };
}
