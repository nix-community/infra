{ pkgs, ... }: {
  # Used to find the project root
  projectRootFile = ".git/config";

  package = pkgs.treefmt2;

  programs = {
    deadnix.enable = true;
    hclfmt.enable = true;
    nixpkgs-fmt.enable = true;
    prettier.enable = true;
    ruff.check = true;
    ruff.format = true;
    statix.enable = true;
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
    actionlint = {
      command = pkgs.actionlint;
      includes = [ ".github/workflows/*.yml" ];
    };

    editorconfig-checker = {
      command = pkgs.editorconfig-checker;
      includes = [ "*" ];
      excludes = [ "*.age" ];
      priority = 9; # last
    };

    # nix
    deadnix.priority = 1;
    statix.priority = 2;
    nixpkgs-fmt.priority = 3;

    # python
    ruff-check.priority = 1;
    ruff-format.priority = 2;
    mypy-tasks.priority = 3;

    prettier = {
      options = [
        "--write"
        "--prose-wrap"
        "never"
      ];
      excludes = [
        "*secrets.yaml"
      ];
    };
  };
}
