{ pkgs ? import <nixpkgs> {}
, sops-import-keys-hook
, deploykit
}:

with pkgs;
mkShellNoCC {
  sopsPGPKeyDirs = [
    "./keys"
  ];

  buildInputs = with pkgs; [
    (terraform.withPlugins (
      p: [
        p.cloudflare
        p.null
        p.external
        p.hydra
      ]
    ))
    jq
    sops
    python3.pkgs.invoke
    rsync

    sops-import-keys-hook
    deploykit
  ];
}
