{ config, pkgs, ... }:
{
  sops.secrets.hydra-admin-password.owner = "hydra";
  sops.secrets.hydra-users.owner = "hydra";

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
