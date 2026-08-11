{ lib, ... }:
{
  nix.settings.extra-platforms = [ "x86_64-darwin" ];

  system.activationScripts.postActivation.text = lib.mkBefore ''
    if ! pgrep -q oahd; then
      echo installing rosetta... >&2
      softwareupdate --install-rosetta --agree-to-license
    fi
  '';
}
