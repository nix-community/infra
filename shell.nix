{ config
, pkgs
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
        p.sops
        p.tfe
      ]
    ))
    jq
    sops
    ssh-to-age
    (python3.withPackages (
      p: [
        p.deploykit
        p.invoke
      ]
    ))
    rsync
    config.treefmt.build.wrapper
  ];
}
