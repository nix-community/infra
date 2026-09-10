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
  nix-eval-jobs = prev.nix-eval-jobs.overrideAttrs (
    _: p: {
      version = "2.35.2-unstable-2026-09-01";
      src = final.fetchFromGitHub {
        owner = "NixOS";
        repo = "nix-eval-jobs";
        rev = "55e658518ae417cf26f36643fcfdebe5c5db17aa";
        hash = "sha256-4z5GnNd9cbkKChaovYghlxuh1k5rYlxNT7wpZeR1oU0=";
      };
      buildInputs = (p.buildInputs or [ ]) ++ [ final.mimalloc ];
    }
  );
  nixVersions = prev.nixVersions.extend (
    _: super:
    let
      prefetchInputsPatch = final.fetchpatch {
        name = "prefetch-inputs.patch";
        url = "https://github.com/NixOS/nix/commit/f0008d095dad1554de5f54233f8b5b3541865a89.patch";
        hash = "sha256-3QBE/cmolXVFcak1T49fC2vftb9CJyUsoJ4Z7WDqVJ4=";
      };
    in
    {
      nixComponents_2_34 = super.nixComponents_2_34.appendPatches [
        # backported for 2.34.9
        prefetchInputsPatch
      ];
      nixComponents_2_35 = super.nixComponents_2_35.appendPatches [
        # backported for 2.35.3
        (final.fetchpatch {
          name = "fetch-to-store.patch";
          url = "https://github.com/NixOS/nix/commit/30820a54b112f4842bdb7df28b61b2a607e54033.patch";
          hash = "sha256-Yvn9a059LvW9FkSGH20LRPlBIhmVqQxGMBXke+hxkgs=";
        })
        # backported for 2.35.3
        prefetchInputsPatch
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
  rfc39 = final.rustPlatform.buildRustPackage {
    pname = "rfc39";
    version = "0-unstable-2026-09-05";
    src = final.fetchFromGitHub {
      owner = "NixOS";
      repo = "rfc39";
      rev = "9e5447bd68a580bcb641e8682b9c63b7a9ebc51e";
      hash = "sha256-c/9qZ921J0dtyo5+thVpchTOWVAVqeZRpNuhvYTCBow=";
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
