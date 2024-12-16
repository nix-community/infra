{
  final,
  prev,
  inputs,
  ...
}:
{
  hydra = (prev.hydra.override { nix = final.nixVersions.nix_2_24; }).overrideAttrs (o: {
    version = inputs.hydra.shortRev;
    src = inputs.hydra;
    buildInputs = o.buildInputs ++ [ final.perlPackages.DBIxClassHelpers ];
  });
  sk-libfido2 = prev.openssh.overrideAttrs (o: {
    pname = "sk-libfido2";
    # rebase of https://github.com/openssh/openssh-portable/commit/ca0697a90e5720ba4d76cb0ae9d5572b5260a16c
    patches = o.patches ++ [ ./sk-libfido2.patch ];
    configureFlags = o.configureFlags ++ [ "--with-security-key-standalone" ];
    buildFlags = [
      "PATHS="
      "SK_STANDALONE=sk-libfido2.dylib"
    ];
    installPhase = "install sk-libfido2.dylib -Dt $out";
    postInstall = null;
    doCheck = false;
  });
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
