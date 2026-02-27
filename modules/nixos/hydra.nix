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
  ];
in
{
  sops.secrets.hydra-admin-password.owner = "hydra";
  sops.secrets.hydra-users.owner = "hydra";

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
      config.services.hydra.package
    ];
    script =
      let
        # Create user accounts, github or hydra, format:
        # github;email;$role;;
        # hydra;user;$role;password-hash;
        # Password hash is computed by applying sha1 to the password.
        hydra-github-users = pkgs.writeText "hydra-github-users" ''
          github;adisbladis@gmail.com;admin;;
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
