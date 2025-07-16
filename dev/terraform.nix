{
  perSystem =
    { config, pkgs, ... }:
    {
      devShells.terraform = pkgs.mkShellNoCC { packages = [ config.packages.terraform ]; };
      packages = {
        terraform = pkgs.opentofu.withPlugins (p: [
          p.github
          p.hydra
          p.sops
        ]);
        terraform-validate =
          pkgs.runCommand "terraform-validate"
            {
              buildInputs = with pkgs; [
                config.packages.terraform
                json-sort
                nix
              ];
              files = pkgs.lib.fileset.toSource rec {
                root = ../terraform;
                fileset = pkgs.lib.fileset.unions [
                  root
                ];
              };
            }
            # https://code.tvl.fyi/commit/tools/checks/default.nix?id=e0c6198d582970fa7b03fd885ca151ec4964f670
            ''
              set -e
              export NIX_STATE_DIR=$TMPDIR/state NIX_STORE_DIR=$TMPDIR/store
              cp --no-preserve=mode -rT $files .
              nix --extra-experimental-features nix-command eval --json -f hydra-nixpkgs.nix | json-sort > hydra-nixpkgs.tf.json
              diff -u $files/hydra-nixpkgs.tf.json hydra-nixpkgs.tf.json
              tofu init -upgrade -backend=false -input=false
              tofu validate
              touch $out
            '';
      };
    };
}
