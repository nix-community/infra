{ pkgs, ... }:
{
  # Used to find the project root
  projectRootFile = ".git/config";

  programs = {
    actionlint.enable = true;
    deadnix.enable = true;
    dnscontrol.enable = true;
    keep-sorted.enable = true;
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

    dnscontrol.includes = [ "*dnsconfig.js" ];

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
        "config.yaml"
        "*dnsconfig.js"
        "docs/sponsors.md"
        "*secrets.yaml"
        "modules/secrets/*.yaml"
      ];
    };
  };
}
