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

  build01 = { ... }: {
    imports = [
      ./build01/configuration.nix
    ];

    deployment.targetHost = "94.130.143.84";
  };

  build02 = { ... }: {
    imports = [
      ./build02/configuration.nix
    ];

    deployment.targetHost = "95.217.109.189";
  };

  build03 = { ... }: {
    imports = [
      ./build03/configuration.nix
    ];

    deployment.targetHost = "build03.nix-community.org";
  };

  build04 = { ... }: {
    imports = [
      ./build04/configuration.nix
    ];
    deployment.targetHost = "158.101.223.107";
  };
}
