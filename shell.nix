{ system ? builtins.currentSystem }:
let
  pkgs = import ./nix { inherit system; };
in
pkgs.mkShell {

  NIX_PATH = "nixpkgs=${toString pkgs.path}";

  NIXOPS_DEPLOYMENT = "nix-community-infra";
  NIXOPS_STATE = toString ./state/deployment-state.nixops;

  buildInputs = with pkgs.nix-community-infra; [
    git-crypt
    niv
    nixops
    terraform
  ];

  # terraform cloud without the remote execution part
  TF_FORCE_LOCAL_BACKEND = "1";
  TF_CLI_CONFIG_FILE = toString ./secrets/terraformrc;

  shellHooks = ''
    export CLOUDFLARE_API_TOKEN=$(< ./secrets/cloudflare-api-token)
    export VPSADMIN_API_TOKEN=$(< ./secrets/vpsadmin-token)
  '';
}
