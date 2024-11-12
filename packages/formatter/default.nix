{
  flake,
  inputs,
  pkgs,
  ...
}:
let
  formatter = inputs.treefmt-nix.lib.mkWrapper pkgs {
    imports = [ "${flake}/dev/treefmt.nix" ];
  };

  passthru.tests.check =
    pkgs.runCommand "format-check"
      {
        nativeBuildInputs = [
          formatter
          pkgs.git
        ];
        meta.platforms = [ "x86_64-linux" ];
      }
      ''
        export HOME=$NIX_BUILD_TOP/home

        # keep timestamps so that treefmt is able to detect mtime changes
        cp --no-preserve=mode --preserve=timestamps -r ${flake} source
        cd source
        git init --quiet
        git add .
        treefmt --no-cache
        if ! git diff --exit-code; then
          echo "-------------------------------"
          echo "aborting due to above changes ^"
          exit 1
        fi
        touch $out
      '';
in
formatter // { inherit passthru; }
