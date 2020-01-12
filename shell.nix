let
  sources = import ./nix/sources.nix;

  pkgs = import sources.nixpkgs {
    config = {};
    overlays = [];
  };

in pkgs.mkShell {

  NIX_PATH="nixpkgs=${toString pkgs.path}";

  NIXOPS_DEPLOYMENT="nix-community-infra";
  NIXOPS_STATE="./state/deployment-state.nixops";

  buildInputs = [
    pkgs.git-crypt
    pkgs.nixops
  ];
}
