{ self, withSystem, ... }:
{
  herculesCI = herculesCI: {
    onPush.default.outputs.effects = withSystem "x86_64-linux" (
      { hci-effects, ... }:
      let
        hosts = (import "${self}/modules/shared/known-hosts.nix").programs.ssh.knownHosts;
      in
      builtins.listToAttrs (
        map
          (x: {
            name = x;
            value = hci-effects.runIf (herculesCI.config.repo.branch == "master") (
              hci-effects.runNixDarwin {
                ssh.destination = "customer@${x}.nix-community.org";
                configuration = self.darwinConfigurations.${x};
                secretsMap.ssh-deployment = "ssh-deployment";
                userSetupScript = ''
                  writeSSHKey ssh-deployment
                  cat >>~/.ssh/known_hosts <<EOF
                  ${toString hosts.${x}.hostNames} ${hosts.${x}.publicKey}
                  EOF
                '';
              }
            );
          })
          [
            "darwin01"
            "darwin02"
          ]
      )
    );
  };
}
