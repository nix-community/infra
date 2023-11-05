{ src ? { ref = null; } }:
let
  self = builtins.getFlake (toString ./.);
  effects = self.inputs.hercules-ci-effects.lib.withPkgs self.inputs.nixpkgs.legacyPackages.x86_64-linux;
in
{
  cachix-deploy-darwin = effects.runIf (src.ref == "refs/heads/master")
    (effects.runCachixDeploy {
      deployJsonFile = self.packages.x86_64-linux.cachix-deploy-spec-darwin;
      async = false;
    });
  cachix-deploy-nixos = effects.runIf (src.ref == "refs/heads/master")
    (effects.runCachixDeploy {
      deployJsonFile = self.packages.x86_64-linux.cachix-deploy-spec-nixos;
      async = true;
    });
}
