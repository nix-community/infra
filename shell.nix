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
    pkgs.niv
    pkgs.nixops
    (pkgs.terraform.withPlugins (p: [
      p.cloudflare
    ]))
  ];

  # terraform cloud without the remote execution part
  TF_FORCE_LOCAL_BACKEND = "1";
  TF_CLI_CONFIG_FILE = toString ./secrets/terraformrc;

  shellHooks = ''
    export CLOUDFLARE_API_TOKEN=$(< ./secrets/cloudflare-api-token)
  '';
}
