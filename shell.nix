{ pkgs
, treefmt
}:

with pkgs;
mkShellNoCC {
  buildInputs = [
    (terraform.withPlugins (
      p: [
        p.cloudflare
        p.external
        p.hydra
        p.null
        p.tfe
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
