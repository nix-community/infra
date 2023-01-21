{ pkgs
, treefmt
}:

with pkgs;
mkShellNoCC {
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
  ];
}
