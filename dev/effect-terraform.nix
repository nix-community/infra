{
  config,
  inputs,
  withSystem,
  ...
}:
let
  terraform = withSystem config.defaultEffectSystem (
    { config, pkgs, ... }:
    let
      inherit (inputs.nixbot.lib.effects { inherit pkgs; }) mkEffect;
    in
    args:
    mkEffect (
      {
        inputs = [ config.packages.terraform ];
        checkout = true;
        userSetupScript = ''
          export TF_INPUT=0 TF_IN_AUTOMATION=0
          cd terraform
          tofu init
        '';
        lock = "infra-terraform";
      }
      // args
    )
  );
in
{
  herculesCI = {
    onEvent.pull_request.terraform-plan = terraform {
      when = {
        modified = [ "terraform/*" ];
        permission = "write";
        status = [ "succeeded" ];
      };
      effectScript = ''
        tofu plan | nixbot-pr-comment --replace-marker terraform-plan
      '';
    };
    onEvent.comment.terraform-apply = terraform {
      when = {
        commands = [ "/nixbot terraform apply" ];
        modified = [ "terraform/*" ];
        permission = "write";
        status = [ "succeeded" ];
      };
      effectScript = ''
        tofu apply -auto-approve | nixbot-pr-comment --replace-marker terraform-apply
      '';
    };
  };
}
