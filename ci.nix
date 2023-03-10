# Add derivations to be built from the cache to this file
{ system ? builtins.currentSystem
, src ? { ref = null; }
}:
let
  self = builtins.getFlake (toString ./.);
  inherit (self.inputs.nixpkgs) lib;
  stripDomain = name: lib.head (builtins.match "(.*).nix-community.org" name);

  effects = self.inputs.hercules-ci-effects.lib.withPkgs self.inputs.nixpkgs.legacyPackages.x86_64-linux;
  terraform-deploy =
    effects.runIf (src.ref == "refs/heads/trying" || src.ref == "refs/heads/staging")
      (effects.mkEffect {
        name = "terraform-deploy";
        inputs = [ (builtins.getFlake (toString ./terraform/.)).outputs.devShells.x86_64-linux.default.nativeBuildInputs ];
        src = lib.cleanSource ./.;
        secretsMap.tf-secrets = "tf-secrets";
        effectScript = ''
          export TF_IN_AUTOMATION=1
          export TF_INPUT=0
          export SOPS_AGE_KEY="$(readSecretString tf-secrets .SOPS_AGE_KEY)"
          export TF_TOKEN_app_terraform_io="$(readSecretString tf-secrets .TF_TOKEN_app_terraform_io)"

          pushd terraform
          terraform init
          terraform validate
          if [[ ${src.ref} == "refs/heads/staging" ]]; then
            terraform apply -auto-approve
          else
            terraform plan
          fi
        '';
      });
in
(lib.mapAttrs' (name: config: lib.nameValuePair "nixos-${stripDomain name}" config.config.system.build.toplevel) self.outputs.nixosConfigurations) //
{
  # FIXME: maybe find a more generic solution here?
  devShell-x86_64 = self.outputs.devShells.x86_64-linux.default;
  devShell-aarch64 = self.outputs.devShells.aarch64-linux.default;
  inherit terraform-deploy;
} // self.outputs.checks.x86_64-linux # mainly for treefmt at the moment...
