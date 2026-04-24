{ final, inputs }:

final.lib.makeScope final.newScope (
  import "${inputs.hydra}/packaging/components.nix" {
    version = "0.1";
    releaseVersion = "0.1";
    craneLib = inputs.crane.mkLib final;
    nixComponents = final.nixVersions.nixComponents_2_35;
    rawSrc = inputs.hydra;
  }
)
