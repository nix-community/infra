{ pkgs, ... }:
let
  excludes = [
    # vendored from external source, file is formatted but isn't compliant with statix
    "hosts/build02/packages-with-update-script.nix"
  ];
in
{
  # Used to find the project root
  projectRootFile = ".git/config";

  programs = {
    actionlint.enable = pkgs.stdenv.hostPlatform.isLinux;
    deadnix.enable = true;
    dnscontrol.enable = true;
    keep-sorted.enable = true;
    nixf-diagnose.enable = true;
    nixfmt.enable = true;
    ruff-check.enable = true;
    ruff-format.enable = true;
    rumdl-check.enable = true;
    shellcheck.enable = true;
    shfmt.enable = true;
    statix.enable = true;
    terraform.enable = true;
  };

  programs.yamlfmt = {
    enable = true;
    settings.formatter.retain_line_breaks_single = true;
    excludes = [
      "*secrets.yaml"
      "modules/secrets/*.yaml"
    ];
  };

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
    deadnix = {
      inherit excludes;
      priority = 1;
    };
    nixf-diagnose = {
      inherit excludes;
      priority = 2;
    };
    statix = {
      inherit excludes;
      priority = 3;
    };
    nixfmt.priority = 4;

    # python
    ruff-check.priority = 1;
    ruff-format.priority = 2;

    python-mypy = {
      priority = 3;
      command = pkgs.mypy;
      options = [
        "--python-executable"
        (pkgs.lib.getExe pkgs.deploykitEnv)
      ];
      includes = [ "tasks.py" ];
    };
  };
}
