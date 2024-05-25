{ config, pkgs, ... }:
{
  devShells.mkdocs = pkgs.mkShellNoCC {
    inputsFrom = [
      config.packages.docs
    ];
  };
  packages = {
    docs = pkgs.runCommand "docs"
      {
        buildInputs = [
          pkgs.python3.pkgs.mkdocs-material
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
  };
}
