{ inputs, self, ... }:
let
  pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
  inherit (inputs.nixbot.lib.effects { inherit pkgs; }) mkEffect;
in
{
  herculesCI = {
    onEvent.pull_request.reboot = mkEffect {
      when = {
        permission = "write";
        status = [ "succeeded" ];
      };
      checkout = true;
      lock = "infra-reboot";
      inputs = with pkgs; [
        curl
        diffutils
        gh
        jq
      ];
      effectScript = ''
        incoming_outpaths=${self.checks.x86_64-linux.outpaths}
        ${builtins.readFile ./effect-reboot.bash}
      '';
    };
  };
}
