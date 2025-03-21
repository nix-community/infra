{
  final,
  prev,
  inputs,
  ...
}:
{
  fish = prev.fish.overrideAttrs (
    _:
    final.lib.optionalAttrs (final.stdenv.hostPlatform.system == "aarch64-linux") {
      doCheck = false;
    }
  );
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
  hydra = (prev.hydra.override { nix = final.nixVersions.nix_2_24; }).overrideAttrs (o: {
    version = inputs.hydra.shortRev;
    src = inputs.hydra;
    buildInputs = o.buildInputs ++ [ final.perlPackages.DBIxClassHelpers ];
  });
  kitty = prev.kitty.overrideAttrs (
    _:
    final.lib.optionalAttrs (final.stdenv.hostPlatform.system == "aarch64-darwin") {
      doInstallCheck = false;
    }
  );
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
  terraform-providers = prev.terraform-providers // {
    cloudflare = (prev.terraform-providers.cloudflare.override { rev = "v4.52.0"; }).overrideAttrs (_: {
      src = final.fetchFromGitHub {
        owner = "cloudflare";
        repo = "terraform-provider-cloudflare";
        rev = "v4.52.0";
        hash = "sha256-rgXsROzfjtUw994JH8x+j/UNMyl7E9cZ+77Fczc3uB8=";
      };
      vendorHash = "sha256-RULgejA/RTDHhRJRiqlgckK4Ut3GLvIE081/i6gQTjI=";
    });
  };
}
