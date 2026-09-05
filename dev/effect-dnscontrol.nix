{ inputs, ... }:
let
  pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
  inherit (inputs.nixbot.lib.effects { inherit pkgs; }) mkEffect;

  dnscontrol =
    args:
    mkEffect (
      {
        inputs = [ pkgs.dnscontrol ];
        checkout = true;
        secretsMap.cloudflare-dnscontrol = "cloudflare-dnscontrol";
        userSetupScript = ''
          token=$(jq -r '.cloudflare-dnscontrol.data.token' "$HERCULES_CI_SECRETS_JSON")
          export CLOUDFLARE_API_TOKEN=$token
          cd dnscontrol
        '';
        lock = "infra-dnscontrol";
      }
      // args
    );
in
{
  herculesCI = {
    onEvent.pull_request.dnscontrol-preview = dnscontrol {
      when = {
        modified = [ "dnscontrol/*" ];
        permission = "write";
        status = [ "succeeded" ];
      };
      effectScript = ''
        dnscontrol preview | nixbot-pr-comment --replace-marker dnscontrol-preview
      '';
    };
    onEvent.comment.dnscontrol-push = dnscontrol {
      when = {
        commands = [ "/nixbot dnscontrol push" ];
        modified = [ "dnscontrol/*" ];
        permission = "write";
        status = [ "succeeded" ];
      };
      effectScript = ''
        dnscontrol push | nixbot-pr-comment --replace-marker dnscontrol-push
      '';
    };
  };
}
