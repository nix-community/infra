{ self, withSystem, ... }:
{
  herculesCI = { config, ... }:
    withSystem "x86_64-linux" ({ hci-effects, pkgs, self', ... }:
      let
        # using the drv path here avoids downloading the closure on the deploying machine
        darwin02 = builtins.unsafeDiscardStringContext self.darwinConfigurations.darwin02.config.system.build.toplevel.drvPath;
        darwin03 = builtins.unsafeDiscardStringContext self.darwinConfigurations.darwin03.config.system.build.toplevel.drvPath;

        inherit (config.repo) ref;
        inherit (hci-effects) mkEffect runIf;
        inherit (pkgs.lib) hasPrefix;
      in
      {
        onPush.default.outputs.effects = {
          darwin-deploy = runIf (hasPrefix "refs/heads/gh-readonly-queue/master/" ref)
            (mkEffect {
              name = "darwin-deploy";
              secretsMap.hercules-ssh = "hercules-ssh";
              effectScript = ''
                writeSSHKey hercules-ssh
                cat >>~/.ssh/known_hosts <<EOF
                darwin02.nix-community.org ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBt6uTauhRbs5A6jwAT3p3i3P1keNC6RpaA1Na859BCa
                darwin03.nix-community.org ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKX7W1ztzAtVXT+NBMITU+JLXcIE5HTEOd7Q3fQNu80S
                EOF
                ${hci-effects.ssh { destination = "m1@darwin02.nix-community.org"; } ''
                  set -eux
                  newProfile=$(nix-store --realise ${darwin02})
                  sudo -H nix-env --profile /nix/var/nix/profiles/system --set $newProfile
                  $newProfile/sw/bin/darwin-rebuild activate
                  set +x
                ''}
                ${hci-effects.ssh { destination = "hetzner@darwin03.nix-community.org"; } ''
                  set -eux
                  newProfile=$(nix-store --realise ${darwin03})
                  sudo -H nix-env --profile /nix/var/nix/profiles/system --set $newProfile
                  $newProfile/sw/bin/darwin-rebuild activate
                  set +x
                ''}
              '';
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
