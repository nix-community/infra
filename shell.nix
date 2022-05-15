{ pkgs ? import <nixpkgs> {}
, sops-import-keys-hook
}:

with pkgs;
mkShell {
  sopsPGPKeyDirs = [
    "./keys"
  ];

  buildInputs = with pkgs; [
    terraform
    (terraform.withPlugins (
      p: [
        p.cloudflare
        p.null
        p.external
        p.hydra
      ]
    ))
    sops
    python3.pkgs.invoke
    rsync

    sops-import-keys-hook
  ];
}
