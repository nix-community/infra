{
  final,
  inputs,
  prev,
  ...
}:
{
  deploykitEnv = final.python3.withPackages (ps: [
    ps.deploykit
    ps.invoke
  ]);
  nixVersions = prev.nixVersions.extend (
    _: super: {
      nixComponents_2_35 = super.nixComponents_2_35.appendPatches [
        (final.fetchpatch {
          name = "fetch-to-store.patch";
          url = "https://github.com/NixOS/nix/commit/30820a54b112f4842bdb7df28b61b2a607e54033.patch";
          hash = "sha256-Yvn9a059LvW9FkSGH20LRPlBIhmVqQxGMBXke+hxkgs=";
        })
      ];
    }
  );
  nixbot-cli = final.symlinkJoin {
    name = "nixbot-cli";
    paths = [ inputs.nixbot.packages.${final.stdenv.hostPlatform.system}.nixbot-cli ];
    nativeBuildInputs = [ final.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/nbo --set NIXBOT_URL "https://nixbot.nix-community.org"
    '';
  };
  prometheus-alertmanager =
    let
      ui = prev.prometheus-alertmanager.passthru.elmUi.overrideAttrs (super: {
        postPatch = super.postPatch + ''
          substituteInPlace elm.json --replace-fail "0.19.1" "0.19.2"
        '';
      });
    in
    prev.prometheus-alertmanager.overrideAttrs {
      postPatch = ''
        cp -r ${ui}/. ui/app/dist
      '';
    };
  rfc39 = final.rustPlatform.buildRustPackage {
    pname = "rfc39";
    version = "0-unstable-2025-05-21";
    src = final.fetchFromGitHub {
      owner = "NixOS";
      repo = "rfc39";
      rev = "5f40cb211f39f22e68e10075e5875f0b692e1ae1";
      hash = "sha256-tyt7Mz7+varMQuKxQtqTHN7KXZEnBVLTaHBP/FI+wNY=";
    };
    cargoHash = "sha256-FwQbHgixrPWCw/nMqmUAQ9RRM1Vx3mI4/zUxkE+pgCM=";
    env = {
      OPENSSL_DIR = "${final.lib.getDev final.openssl}";
      OPENSSL_LIB_DIR = "${final.lib.getLib final.openssl}/lib";
      OPENSSL_NO_VENDOR = 1;
    };
    doCheck = false;
  };
}
