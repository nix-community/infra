{ self, withSystem, ... }:
{
  herculesCI = { config, ... }:
    withSystem "x86_64-linux" ({ hci-effects, pkgs, self', ... }:
      let
        # using the drv path here avoids downloading the closure on the deploying machine
        drv = builtins.unsafeDiscardStringContext self.darwinConfigurations.darwin02.config.system.build.toplevel.drvPath;
      in
      {
        onPush.default.outputs.effects = {
          darwin-deploy = hci-effects.runIf (pkgs.lib.hasPrefix "refs/heads/gh-readonly-queue/master/" config.repo.ref)
            (hci-effects.mkEffect {
              secretsMap.hercules-ssh = "hercules-ssh";
              effectScript = ''
                writeSSHKey hercules-ssh
                cat >>~/.ssh/known_hosts <<EOF
                darwin02.nix-community.org ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBt6uTauhRbs5A6jwAT3p3i3P1keNC6RpaA1Na859BCa
                EOF
                ${hci-effects.ssh { destination = "m1@darwin02.nix-community.org"; } ''
                  set -eu
                  newProfile=$(nix-store --realise ${drv})
                  sudo -H nix-env --profile /nix/var/nix/profiles/system --set $newProfile
                  $newProfile/sw/bin/darwin-rebuild activate
                ''}
              '';
            });
          terraform-deploy = hci-effects.runIf (pkgs.lib.hasPrefix "refs/heads/gh-readonly-queue/master/" config.repo.ref)
            (hci-effects.mkEffect {
              name = "terraform-deploy";
              inputs = [ self'.devShells.terraform.nativeBuildInputs ];
              src = toString self;
              secretsMap.tf-secrets = "tf-secrets";
              effectScript = ''
                export TF_IN_AUTOMATION=1
                export TF_INPUT=0
                export SOPS_AGE_KEY="$(readSecretString tf-secrets .SOPS_AGE_KEY)"
                export TF_TOKEN_app_terraform_io="$(readSecretString tf-secrets .TF_TOKEN_app_terraform_io)"

                pushd terraform
                terraform init
                terraform validate
                terraform apply -auto-approve
              '';
            });
        };
      }
    );
}
