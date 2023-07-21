{ self, withSystem, ... }:
{
  herculesCI = { config, ... }:
    withSystem "x86_64-linux" ({ hci-effects, pkgs, self', ... }:
      let
        inherit (config.repo) ref;
        inherit (hci-effects) mkEffect runCachixDeploy runIf;
        inherit (pkgs.lib) hasPrefix;
      in
      {
        onPush.default.outputs.effects = {
          cachix-deploy = runIf (hasPrefix "refs/heads/gh-readonly-queue/master/" ref)
            (runCachixDeploy {
              deploy.agents = {
                build01 = builtins.unsafeDiscardStringContext self.nixosConfigurations.build01.config.system.build.toplevel;
              };
            });
          terraform-deploy = runIf (hasPrefix "refs/heads/gh-readonly-queue/master/" ref)
            (mkEffect {
              name = "terraform-deploy";
              inputs = [ self'.devShells.terraform.nativeBuildInputs ];
              src = self;
              secretsMap.tf-secrets = "tf-secrets";
              effectScript = ''
                export TF_IN_AUTOMATION=1
                export TF_INPUT=0
                export SOPS_AGE_KEY="$(readSecretString tf-secrets .SOPS_AGE_KEY)"
                export TF_TOKEN_app_terraform_io="$(readSecretString tf-secrets .TF_TOKEN_app_terraform_io)"

                set -eux
                pushd terraform
                terraform init
                terraform validate
                terraform apply -auto-approve
                set +x
              '';
            });
        };
      }
    );
}
