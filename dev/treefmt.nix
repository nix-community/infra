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
      pipeline = "yaml";
      priority = 1;
    };

    deadnix = {
      pipeline = "nix";
      priority = 1;
    };

    statix = {
      pipeline = "nix";
      priority = 2;
    };

    nixpkgs-fmt = {
      pipeline = "nix";
      priority = 3;
    };

    ruff-check = {
      pipeline = "python";
      priority = 1;
    };

    ruff-format = {
      pipeline = "python";
      priority = 2;
    };

    mypy-tasks = {
      pipeline = "python";
      priority = 3;
    };

    prettier = {
      options = [
        "--write"
        "--prose-wrap"
        "never"
      ];
      excludes = [
        "*secrets.yaml"
      ];
      pipeline = "yaml";
      priority = 2;
    };
  };
}
