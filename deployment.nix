with builtins;
let
  secrets = import ./secrets.nix;

  # Copied from <nixpkgs/lib>
  removeSuffix = suffix: str:
    let
      sufLen = stringLength suffix;
      sLen = stringLength str;
    in
    if
      sufLen <= sLen && suffix == substring (sLen - sufLen) sufLen str
    then
      substring 0 (sLen - sufLen) str
    else
      str;

in
{
  network.description = "nix-community infra";
  network.nixConfig = {
    extra-substituters = "https://nix-community.cachix.org";
    binary-cache-public-keys = "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=";
  };

  build01 = { ... }: {
    imports = [
      ./build01/configuration.nix
    ];

    deployment.targetHost = "94.130.143.84";
    deployment.substituteOnDestination = true;
  };

  build02 = { ... }: {
    imports = [
      ./build02/configuration.nix
    ];

    deployment.targetHost = "95.217.109.189";
    deployment.substituteOnDestination = true;
  };

  build03 = { ... }: {
    imports = [
      ./build03/configuration.nix
    ];

    deployment.targetHost = "build03.nix-community.org";
    deployment.substituteOnDestination = true;
  };

  build04 = { ... }: {
    imports = [
      ./build04/configuration.nix
    ];
    deployment.targetHost = "158.101.223.107";
    deployment.substituteOnDestination = true;
  };
}
