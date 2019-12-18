let
  sources = import ./nix/sources.nix;

  pkgs = import sources.nixpkgs {
    config = {};
    overlays = [];
  };

in pkgs.mkShell {

  NIX_PATH="nixpkgs=${toString pkgs.path}";

  buildInputs = [
    pkgs.git-crypt
    pkgs.nixops
  ];

}
