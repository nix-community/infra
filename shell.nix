{ pkgs ? import <nixpkgs> {}
, sops-import-keys-hook
}:

with pkgs;
mkShell {
  sopsPGPKeyDirs = [
    "./keys"
  ];

  buildInputs = with pkgs; [
    git-crypt
    terraform
    (terraform.withPlugins (
      p: [
        p.cloudflare
        p.null
        p.external
      ]
    ))
    sops
    python3.pkgs.invoke
    rsync

    sops-import-keys-hook
  ];

  # terraform cloud without the remote execution part
  TF_FORCE_LOCAL_BACKEND = "1";
  TF_CLI_CONFIG_FILE = toString ./secrets/terraformrc;

  shellHook = ''
    export CLOUDFLARE_API_TOKEN=$(< ./secrets/cloudflare-api-token)
    export NIX_USER_CONF_FILES="$(pwd)/nix/nix.conf";
  '';
}
