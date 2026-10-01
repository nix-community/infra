{
  pkgs,
  config,
  lib,
  ...
}:
let
  inherit (lib) concatStringsSep;
  localSystems = [
    "builtin"
    pkgs.stdenv.hostPlatform.system
  ]
  ++ config.nix.settings.extra-platforms;
in
{
  # hydra-queue-runner needs to read this key for remote building
  sops.secrets.id_buildfarm.owner = "hydra-queue-runner";

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

  sops.secrets.id_buildfarm = { };

  # delete build logs older than 30 days
  systemd.services.hydra-delete-old-logs = {
    startAt = "Sun 05:45";
    serviceConfig.ExecStart = "${pkgs.findutils}/bin/find /var/lib/hydra/build-logs -type f -mtime +30 -delete";
  };

  # not currently needed, hydra-notify would need to be enabled for declarative jobsets
  systemd.services = {
    hydra-check-space.enable = false;
    hydra-notify.enable = false;
    hydra-send-stats.enable = false;
  };

  environment.etc."nix/hydra/localhost".text = ''
    localhost ${concatStringsSep "," localSystems} - 3 1 ${concatStringsSep "," config.nix.settings.system-features} - -
  '';
  environment.etc."nix/hydra/machines".source =
    pkgs.runCommand "machines" { machines = config.environment.etc."nix/machines".text; }
      ''
        printf "$machines" | grep -e bsd -e linux > $out
        substituteInPlace $out --replace-fail 'ssh-ng://' 'ssh://'
        substituteInPlace $out --replace-fail ' 80 ' ' 3 '
      '';

  services.hydra = {
    enable = true;
    # remote builders set in /etc/nix/machines + localhost
    buildMachinesFiles = [
      "/etc/nix/hydra/localhost"
      "/etc/nix/hydra/machines"
    ];
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
    '';
  };

  sops.secrets.hydra-github-client-secret = {
    owner = "hydra-www";
    group = "hydra";
  };

  services.nginx.virtualHosts."hydra.nix-community.org" = {
    locations."/".proxyPass = "http://localhost:${toString config.services.hydra.port}";
  };
}
