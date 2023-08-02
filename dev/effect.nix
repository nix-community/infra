{ self, withSystem, ... }:
{
  herculesCI = { config, ... }:
    withSystem "x86_64-linux" ({ hci-effects, pkgs, self', ... }:
      let
        inherit (config.repo) ref;
        inherit (hci-effects) mkEffect runCachixDeploy runIf;
        inherit (pkgs.lib) hasPrefix mapAttrs;
      in
      {
        onPush.default.outputs.effects = {
          cachix-deploy = runIf (ref == "refs/heads/master")
            (runCachixDeploy {
              deploy.agents =
                mapAttrs (_: darwin: builtins.unsafeDiscardStringContext darwin.config.system.build.toplevel) self.darwinConfigurations //
                mapAttrs (_: nixos: builtins.unsafeDiscardStringContext nixos.config.system.build.toplevel) self.nixosConfigurations;
              async = true;
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
