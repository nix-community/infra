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
