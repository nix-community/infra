{
  config,
  lib,
  self,
  withSystem,
  ...
}:
let
  inherit ((import "${self}/modules/shared/known-hosts.nix").programs.ssh) knownHosts;
in
{
  herculesCI = herculesCI: {
    onPush.default.outputs.effects = withSystem config.defaultEffectSystem (
      { hci-effects, ... }:
      lib.listToAttrs (
        map (x: {
          name = x;
          value = hci-effects.runIf (herculesCI.config.repo.ref == "refs/heads/master") (
            hci-effects.runNixDarwin {
              ssh.destination = "customer@${x}.nix-community.org";
              configuration = self.darwinConfigurations.${x};
              secretsMap.ssh-deployment = "ssh-deployment";
              userSetupScript = ''
                writeSSHKey ssh-deployment
                cat >> ~/.ssh/known_hosts <<EOF
                ${toString knownHosts.${x}.hostNames} ${knownHosts.${x}.publicKey}
                EOF
              '';
            }
          );
        }) (builtins.attrNames self.darwinConfigurations)
      )
    );
  };
}
