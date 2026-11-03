{
  perSystem =
    { config, pkgs, ... }:
    {
      devShells.terraform = pkgs.mkShellNoCC { packages = [ config.packages.terraform ]; };
      packages = {
        terraform = pkgs.opentofu.withPlugins (p: [
          p.carlpett_sops
          p.hashicorp_tfe
          p.integrations_github
          # archived upstream
          (p.mkProvider {
            hash = "sha256-A9BemEPLhvYzhksvYRfmhQXY3EEdTxQcmjE9+2+BKqg=";
            homepage = "https://registry.terraform.io/providers/DeterminateSystems/hydra";
            owner = "DeterminateSystems";
            repo = "terraform-provider-hydra";
            rev = "v0.1.2";
            spdx = "MPL-2.0";
            vendorHash = null;
          })
        ]);
        terraform-validate =
          pkgs.runCommand "terraform-validate"
            {
              buildInputs = [ config.packages.terraform ];
              files = pkgs.lib.fileset.toSource rec {
                root = ../terraform;
                fileset = pkgs.lib.fileset.unions [
                  root
                ];
              };
            }
            # https://code.tvl.fyi/commit/tools/checks/default.nix?id=e0c6198d582970fa7b03fd885ca151ec4964f670
            ''
              cp --no-preserve=mode -r $files/* .
              tofu init -upgrade -backend=false -input=false
              tofu validate
              touch $out
            '';
      };
    };
}
