{
  config,
  lib,
  self,
  withSystem,
  ...
}:
let
  inherit (config) defaultEffectSystem;
  inherit ((import "${self}/modules/shared/known-hosts.nix").programs.ssh) knownHosts;

  targets = builtins.attrNames self.darwinConfigurations;

  buildable = effect: (effect.overrideAttrs { isEffect = false; }).inputDerivation;

  deploy = x: {
    ssh.destination = "customer@${x}.nix-community.org";
    configuration = self.darwinConfigurations.${x};
    secretsMap.ssh-deployment = "ssh-deployment";
    userSetupScript = ''
      writeSSHKey ssh-deployment
      cat >> ~/.ssh/known_hosts <<EOF
      ${toString knownHosts.${x}.hostNames} ${knownHosts.${x}.publicKey}
      EOF
    '';
  };
in
{
  perSystem =
    { hci-effects, system, ... }:
    lib.optionalAttrs (system == defaultEffectSystem) {
      checks.darwin-effect-is-buildable = buildable (
        hci-effects.runNixDarwin (deploy (lib.last targets))
      );
    };

  herculesCI = herculesCI: {
    onPush.default.outputs.effects = withSystem defaultEffectSystem (
      { hci-effects, ... }:
      lib.listToAttrs (
        map (x: {
          name = x;
          value = hci-effects.runIf (herculesCI.config.repo.ref == "refs/heads/master") (
            hci-effects.runNixDarwin (deploy x)
          );
        }) targets
      )
    );
  };
}
