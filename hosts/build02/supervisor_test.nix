{ pkgs, ... }:

pkgs.runCommand "nixpkgs-update-supervisor-test"
  {
    files = pkgs.lib.fileset.toSource {
      root = ./.;
      fileset = pkgs.lib.fileset.unions [
        ./supervisor.py
        ./supervisor_test.py
      ];
    };
  }
  ''
    ${pkgs.lib.getExe pkgs.supervisorEnv} $files/supervisor_test.py
    touch $out
  ''
