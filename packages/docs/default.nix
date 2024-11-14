{ perSystem, pkgs, ... }:

with pkgs;

runCommand "docs"
  {
    buildInputs = [ python3.pkgs.mkdocs-material ];
    files = lib.fileset.toSource {
      root = ../../.;
      fileset = lib.fileset.unions [
        ../../docs
        ../../mkdocs.yml
      ];
    };
    # meta.platforms = [ "x86_64-linux" ];
    passthru = {
      tests.linkcheck = testers.lycheeLinkCheck rec {
        extraConfig = {
          exclude = [
            "https://fonts.gstatic.com"
            "https://monitoring.nix-community.org/alertmanager" # 401 behind auth
          ];
          include_mail = true;
          include_verbatim = true;
        };
        remap = {
          "https://nix-community.org" = site;
        };
        site = perSystem.self.docs;
      };
    };
  }
  ''
    cd $files
    mkdocs build --strict --site-dir $out
  ''
