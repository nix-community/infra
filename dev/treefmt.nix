{ pkgs, ... }: {
  # Used to find the project root
  projectRootFile = "flake.lock";

  programs.hclfmt.enable = true;

  programs.prettier.enable = true;

  settings.formatter = {
    actionlint = {
      command = pkgs.actionlint;
      includes = [ ".github/workflows/*.yml" ];
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
          ${pkgs.lib.getExe pkgs.ruff} --fix "$@"
          ${pkgs.lib.getExe pkgs.python3.pkgs.black} "$@"
        ''
        "--" # this argument is ignored by bash
      ];
      includes = [ "*.py" ];
    };
  };
}
