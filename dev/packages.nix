{
  final,
  prev,
  ...
}:
{
  grml-zsh-config = prev.grml-zsh-config.overrideAttrs (o: {
    patches = (o.patches or [ ]) ++ [
      (final.fetchpatch {
        name = "use-path_helper-on-macos.patch";
        url = "https://github.com/grml/grml-etc-core/commit/4d8fae2d8c5cee771bb4fc70e0a3cb21e1b839fd.patch";
        hash = "sha256-0rWFlKaO/85T8/2mYa5P9DOiP5rcPqt9CjTcoLpH5/E=";
        revert = true;
      })
    ];
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
