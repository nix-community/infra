{ config, pkgs, ... }:
{
  devShells.mkdocs = pkgs.mkShellNoCC { inputsFrom = [ config.packages.docs ]; };
  packages = {
    docs =
      pkgs.runCommand "docs"
        {
          buildInputs = [
            pkgs.python3.pkgs.mkdocs-material
            pkgs.python3.pkgs.mkdocs-material.optional-dependencies.recommended
          ];
          files = pkgs.lib.fileset.toSource {
            root = ../.;
            fileset = pkgs.lib.fileset.unions [
              ../docs
              ../mkdocs.yml
            ];
          };
        }
        ''
          cd $files
          mkdocs build --strict --site-dir $out
        '';
    docs-linkcheck = pkgs.testers.lycheeLinkCheck rec {
      extraConfig = {
        include_mail = true;
        include_verbatim = true;
      };
      remap = {
        "https://nix-community.org" = site;
      };
      site = config.packages.docs;
    };
  };
}
