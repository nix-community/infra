{
  perSystem =
    { pkgs, ... }:
    {
      packages.sops-check =
        pkgs.runCommand "sops-check"
          {
            buildInputs = with pkgs; [
              diffutils
              nix
              sops
              yq-go
            ];
            files = pkgs.lib.fileset.toSource {
              root = ../.;
              fileset = pkgs.lib.fileset.unions [
                (pkgs.lib.fileset.fromSource (pkgs.lib.sources.sourceFilesBySuffices ../. [ ".yaml" ]))
                ../modules/shared/known-hosts.nix
                ../sops.json
                ../sops.nix
                ../users
              ];
            };
          }
          ''
            set -e
            export NIX_STATE_DIR=$TMPDIR/state NIX_STORE_DIR=$TMPDIR/store
            cp --no-preserve=mode -rT $files .
            nix --extra-experimental-features nix-command eval --json -f sops.nix | yq e -P - > .sops.yaml
            diff -u $files/.sops.yaml .sops.yaml
            shopt -s globstar && sops updatekeys --yes **/secrets.yaml modules/secrets/*.yaml
            touch $out
          '';
    };
}
