{ pkgs
, sops-import-keys-hook
, treefmt
}:

with pkgs;
mkShellNoCC {
  sopsPGPKeyDirs = [
    "${toString ./.}/keys"
  ];

  buildInputs = [
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
    (python3.withPackages (
      p: [
        p.deploykit
        p.invoke
      ]
    ))
    rsync
    treefmt

    sops-import-keys-hook
  ];
}
