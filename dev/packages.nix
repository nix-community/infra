{
  final,
  inputs,
  ...
}:
{
  hydra = final.callPackage (import "${inputs.hydra}/package.nix") {
    inherit (final.lib) fileset;
    nixComponents = final.nixVersions.nixComponents_2_32;
    rawSrc = inputs.hydra;
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
  sotp = final.buildGoModule rec {
    pname = "sotp";
    version = "e7f7c804b1641169ce850d8352fb07294881609e";
    src = final.fetchFromGitHub {
      owner = "getsops";
      repo = "sotp";
      rev = version;
      hash = "sha256-Cu8cZCmM19G5zeMIiiaCwVJee8wrBZP3Ltk1jWKb2vs=";
    };
    vendorHash = "sha256-vQruuohwi53By8UZLrPbRtUrmNbmPt+Sku9hI5J3Dlc=";
    ldflags = [
      "-s"
      "-w"
    ];
    doCheck = false;
  };
}
