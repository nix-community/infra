{ final, inputs }:

final.lib.makeScope final.newScope (
  import "${inputs.hydra}/packaging/components.nix" {
    version = builtins.substring 0 8 inputs.hydra.lastModifiedDate;
    releaseVersion = builtins.substring 0 8 inputs.hydra.lastModifiedDate;
    craneLib = inputs.crane.mkLib final;
    nixComponents = final.nixVersions.nixComponents_2_35;
    rawSrc = inputs.hydra;
  }
)
