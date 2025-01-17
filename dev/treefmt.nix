{ lib, pkgs, ... }:
{
  # Used to find the project root
  projectRootFile = ".git/config";

  programs = {
    actionlint.enable = true;
    deadnix.enable = true;
    nixfmt.enable = true;
    prettier.enable = true;
    ruff-check.enable = true;
    ruff-format.enable = true;
    shellcheck.enable = true;
    shfmt.enable = true;
    statix.enable = true;
    terraform.enable = true;
  };

  programs.mypy = {
    enable = true;
    directories = {
      "tasks" = {
        directory = ".";
        files = [ "*tasks.py" ];
        modules = [ ];
        extraPythonPackages = [
          pkgs.python3.pkgs.deploykit
          pkgs.python3.pkgs.invoke
        ];
      };
    };
  };

  settings.global.excludes = [
    # vendored from external source
    "hosts/build02/packages-with-update-script.nix"
  ];

  settings.formatter = {
    editorconfig-checker = {
      command = pkgs.editorconfig-checker;
      includes = [ "*" ];
      priority = 9; # last
    };

    json-sort-compact = {
      command = pkgs.writeShellScriptBin "json-sort-compact" ''
        for file in "$@"; do
          ${lib.getExe pkgs.jq} \
            'walk(if type == "array" then sort else . end)' \
            --compact-output --sort-keys < "$file" |
            ${lib.getExe' pkgs.moreutils "sponge"} "$file"
        done
      '';
      includes = [ "*report.json" ];
    };

    shellcheck.priority = 1;
    shfmt.priority = 2;

    # nix
    deadnix.priority = 1;
    statix.priority = 2;
    nixfmt.priority = 3;

    # python
    ruff-check.priority = 1;
    ruff-format.priority = 2;
    mypy-tasks.priority = 3;

    prettier = {
      options = [
        "--prose-wrap"
        "never"
      ];
      excludes = [
        "*report.json"
        "config.yaml"
        "*secrets.yaml"
        "modules/secrets/*.yaml"
      ];
    };
  };
}
