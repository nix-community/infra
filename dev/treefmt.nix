{ pkgs, ... }: {
  # Used to find the project root
  projectRootFile = ".git/config";

  programs.hclfmt.enable = true;

  programs.mypy = {
    enable = true;
    directories = {
      "tasks" = {
        directory = ".";
        files = [ "**/tasks.py" ];
        modules = [ ];
        extraPythonPackages = [
          pkgs.python3.pkgs.deploykit
          pkgs.python3.pkgs.invoke
        ];
      };
    };
  };

  programs.prettier.enable = true;

  settings.formatter = {
    actionlint = {
      command = pkgs.actionlint;
      includes = [ ".github/workflows/*.yml" ];
    };

    editorconfig-checker = {
      command = pkgs.editorconfig-checker;
      includes = [ "*" ];
    };

    nix = {
      command = "sh";
      options = [
        "-eucx"
        ''
          ${pkgs.lib.getExe pkgs.deadnix} --edit "$@"

          for i in "$@"; do
            ${pkgs.lib.getExe pkgs.statix} fix "$i"
          done

          ${pkgs.lib.getExe pkgs.nixpkgs-fmt} "$@"
        ''
        "--"
      ];
      includes = [ "*.nix" ];
      excludes = [
        "nix/sources.nix"
        # vendored from external source
        "hosts/build02/packages-with-update-script.nix"
      ];
    };

    prettier = {
      options = [
        "--write"
        "--prose-wrap"
        "never"
      ];
      excludes = [
        "secrets.yaml"
      ];
    };

    python = {
      command = "sh";
      options = [
        "-eucx"
        ''
          ${pkgs.lib.getExe pkgs.ruff} check --fix "$@"
          ${pkgs.lib.getExe pkgs.ruff} format "$@"
        ''
        "--" # this argument is ignored by bash
      ];
      includes = [ "*.py" ];
    };
  };
}
