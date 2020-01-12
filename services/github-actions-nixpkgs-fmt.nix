{ lib, pkgs, ... }:
{
  systemd.services.github-actions-nixpkgs-fmt = {
    description = "Github Actions runner for nixpkgs-fmt";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];

    preStart = ''
      cp \
        /run/keys/github-actions-nixpkgs-fmt-token \
        "$RUNTIME_DIRECTORY"/github-actions-nixpkgs-fmt-token
      chmod 644 "$RUNTIME_DIRECTORY"/github-actions-nixpkgs-fmt-token
    '';

    # https://github.com/actions/runner/blob/master/src/Runner.Listener/CommandSettings.cs
    serviceConfig = {
      PermissionsStartOnly = true;
      DynamicUser = true;
      RuntimeDirectory = "github-actions-nixpkgs-fmt";
      ExecStart = pkgs.writeShellScript "github-actions-nixpkgs-fmt" ''
        set -euo pipefail

        # Load registration token
        token=$(< $RUNTIME_DIRECTORY/github-actions-nixpkgs-fmt-token)
        rm $RUNTIME_DIRECTORY/github-actions-nixpkgs-fmt-token

        # Unpack archive
        cp --no-preserve=owner -R ${pkgs.actions-runner}/* "$RUNTIME_DIRECTORY"
        cd "$RUNTIME_DIRECTORY"

        # Register
        ./with-deps.sh ./config.sh \
          --url https://github.com/nix-community/nixpkgs-fmt \
          --token "$token" \
          --unattended \
          --replace

        # Exec
        exec ./with-deps.sh ./run.sh
      '';
    };
  };
}
