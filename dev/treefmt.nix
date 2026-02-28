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

    ty = {
      priority = 3;
      command = pkgs.ty;
      options = [
        "check"
        "--extra-search-path"
        "${pkgs.deploykitEnv}/${pkgs.deploykitEnv.sitePackages}"
      ]
      ++ pkgs.lib.optionals pkgs.stdenv.hostPlatform.isLinux [
        "--extra-search-path"
        "${pkgs.supervisorEnv}/${pkgs.supervisorEnv.sitePackages}"
      ];
      includes = [ "*.py" ];
      excludes = pkgs.lib.optionals (!pkgs.stdenv.hostPlatform.isLinux) [
        "hosts/build02/supervisor*.py"
      ];
    };
  };
}
