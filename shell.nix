{ system ? builtins.currentSystem }:
let
  sources = import ./nix/sources.nix;
  pkgs = import ./nix { inherit system; };
in
pkgs.mkShell {
  NIX_PATH = "nixpkgs=${toString pkgs.path}";
  # required for morph
  SSH_USER = "root";

  sopsPGPKeyDirs = [
    "./keys"
  ];

  buildInputs = with pkgs.nix-community-infra; [
    git-crypt
    niv
    terraform
    sops
    morph
    invoke
    rsync

    (pkgs.callPackage sources.sops-nix {}).sops-import-keys-hook
  ];

  # terraform cloud without the remote execution part
  TF_FORCE_LOCAL_BACKEND = "1";
  TF_CLI_CONFIG_FILE = toString ./secrets/terraformrc;

  shellHooks = ''
    export CLOUDFLARE_API_TOKEN=$(< ./secrets/cloudflare-api-token)
    export NIX_USER_CONF_FILES="$(pwd)/nix/nix.conf";
  '';
}
