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
    inputs.hydra.nixosModules.queue-runner
    inputs.hydra.nixosModules.web-app
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

  # not currently needed
  systemd.services = {
    hydra-evaluator-check-space.enable = false;
    hydra-queue-runner-check-space.enable = false;
    hydra-send-stats.enable = false;
  };

  sops.secrets.hydra-queue-runner-tokens = { };

  services.hydra-queue-runner-dev = {
    enable = true;
    settings = {
      queueTriggerTimerInS = 300;
      useSubstitutes = true;
      tokenPaths = [ config.sops.secrets.hydra-queue-runner-tokens.path ];
    };
    rest.port = 9090;
  };

  services.hydra-dev = {
    enable = true;
    hydraURL = "https://hydra.nix-community.org";
    notificationSender = "hydra@hydra.nix-community.org";
    port = 3000;
    useSubstitutes = true;
    extraConfig = ''
      evaluator_max_memory_size = 4096
      evaluator_workers = 8
      max_concurrent_evals = 2
      max_output_size = ${toString (8 * 1024 * 1024 * 1024)}

      github_client_id = Ov23ligaoPhIyuYCJ1pp
      github_client_secret_file = ${config.sops.secrets.hydra-github-client-secret.path}

      queue_runner_endpoint = http://localhost:${toString config.services.hydra-queue-runner-dev.rest.port}
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
      inherit (config.systemd.services.hydra-init.environment) HYDRA_DBI;
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
          hydra;hexa;restart-jobs;$argon2id$v=19$m=262144,t=3,p=1$U0JEc2FMT2NTYkJQY1VMMQ$JlHT6wBnwHfMDxNKWTEriQ;
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
