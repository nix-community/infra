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
    (import "${inputs.hydra}/nixos-modules/web-app.nix")
    (import "${inputs.hydra}/nixos-modules/ws-server-module.nix")
  ];

  systemd.services.hydra-init.enableStrictShellChecks = false;

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

  #services.telegraf.extraConfig.inputs.prometheus.urls = [
  #  "http://localhost:${toString config.services.hydra-dev.port}/metrics" # web server
  #];

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

      ws_endpoint = wss://hydra.nix-community.org/ws
    '';
  };

  sops.secrets.hydra-github-client-secret = {
    owner = "hydra-www";
    group = "hydra";
  };

  services.nginx.virtualHosts."hydra.nix-community.org" = {
    locations."/".proxyPass = "http://localhost:${toString config.services.hydra-dev.port}";

    locations."/ws" = {
      proxyPass = "http://${config.services.hydra-ws-dev.bind.address}:${toString config.services.hydra-ws-dev.bind.port}";
      proxyWebsockets = true;
      extraConfig = ''
        proxy_read_timeout 1d;
        proxy_send_timeout 1d;
      '';
    };
  };
}
