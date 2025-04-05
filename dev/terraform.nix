{
  perSystem =
    { config, pkgs, ... }:
    {
      devShells.terraform = pkgs.mkShellNoCC { packages = [ config.packages.terraform ]; };
      packages = {
        terraform = pkgs.terraform.withPlugins (p: [
          p.github
          p.hydra
          p.sops
          p.tfe
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
              terraform init -upgrade -backend=false -input=false
              terraform validate
              touch $out
            '';
      };
    };
}
