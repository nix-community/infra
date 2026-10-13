{
  final,
  inputs,
  ...
}:
{
  deploykitEnv = final.python3.withPackages (ps: [
    ps.deploykit
    ps.invoke
  ]);
  hydraPackages = import ./hydra-packages.nix {
    inherit final inputs;
  };
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
