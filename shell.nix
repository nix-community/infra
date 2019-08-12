let
  nixpkgs = import ./nixpkgs.nix;

  pkgs = import nixpkgs {
    config = {};
    overlays = [];
  };

in pkgs.mkShell {

  NIX_PATH="nixpkgs=${nixpkgs}";

  buildInputs = [
    pkgs.git-crypt
    pkgs.nixops
  ];

}
