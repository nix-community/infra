{
  final,
  prev,
  ...
}:
{
  deploykitEnv = final.python3.withPackages (ps: [
    ps.deploykit
    ps.invoke
  ]);
  # https://github.com/NixOS/nix-eval-jobs/issues/430
  nix-eval-jobs =
    (prev.nix-eval-jobs.override { nixComponents = final.nixVersions.nixComponents_2_34; })
    .overrideAttrs
      rec {
        version = "2.34.3";
        src = final.fetchFromGitHub {
          owner = "NixOS";
          repo = "nix-eval-jobs";
          tag = "v${version}";
          hash = "sha256-YaVQAgBxWbUBFHXLBLzdUyVvuA/DDw80SEnn9iq0Veo=";
        };
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
