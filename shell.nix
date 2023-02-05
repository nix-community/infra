{ config
, pkgs
}:

with pkgs;
mkShellNoCC {
  buildInputs = [
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
