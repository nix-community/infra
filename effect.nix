{ withSystem, ... }:
{
  herculesCI = { config, ... }:
    let
      inherit (config.repo) ref;
    in
    {
      onPush.default.outputs.effects = withSystem "x86_64-linux" ({ hci-effects, pkgs, ... }:
        {
          terraform-deploy =
            hci-effects.runIf (ref == "refs/heads/trying" || ref == "refs/heads/staging")
              (hci-effects.mkEffect {
                name = "terraform-deploy";
                inputs = [ (builtins.getFlake (toString ./terraform/.)).outputs.devShells.x86_64-linux.default.nativeBuildInputs ];
                src = pkgs.lib.cleanSource ./.;
                secretsMap.tf-secrets = "tf-secrets";
                effectScript = ''
                  export TF_IN_AUTOMATION=1
                  export TF_INPUT=0
                  export SOPS_AGE_KEY="$(readSecretString tf-secrets .SOPS_AGE_KEY)"
                  export TF_TOKEN_app_terraform_io="$(readSecretString tf-secrets .TF_TOKEN_app_terraform_io)"

                  pushd terraform
                  terraform init
                  terraform validate
                  if [[ ${ref} == "refs/heads/staging" ]]; then
                    terraform apply -auto-approve
                  else
                    terraform plan
                  fi
                '';
              });
        });
    };
}
