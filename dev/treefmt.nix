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
    ruff-check.enable = true;
    ruff-format.enable = true;
    shellcheck.enable = true;
    shfmt.enable = true;
    statix.enable = true;
    terraform.enable = true;
  };

  programs.mdformat = {
    enable = true;
    excludes = [ "docs/*.md" ];
    settings = {
      number = true;
      wrap = "no";
    };
  };

  programs.yamlfmt = {
    enable = true;
    settings.formatter.retain_line_breaks_single = true;
    excludes = [
      "config.yaml"
      "*secrets.yaml"
      "modules/secrets/*.yaml"
    ];
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

    mdformat-mkdocs = {
      command = pkgs.mdformat.withPlugins (p: [
        p.mdformat-frontmatter
        p.mdformat-mkdocs
        p.mdformat-simple-breaks
      ]);
      options = [
        "--number"
        "--wrap"
        "no"
      ];
      includes = [
        "docs/*.md"
      ];
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

    python-mypy = {
      priority = 3;
      command = pkgs.bash;
      options = with pkgs.python3.pkgs; [
        "-euc"
        ''
          export PYTHONPATH="${
            makePythonPath [
              deploykit
              invoke
            ]
          }"
          ${pkgs.lib.getExe mypy} "$@"
        ''
        "--"
      ];
      includes = [ "tasks.py" ];
    };
  };
}
