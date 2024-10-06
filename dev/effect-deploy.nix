{ self, withSystem, ... }:
{
  herculesCI =
    { config, ... }:
    withSystem "x86_64-linux" (
      { hci-effects, ... }:
      let
        secretsMap.ssh-deployment = "ssh-deployment";
        userSetupScript = ''
          writeSSHKey ssh-deployment
          cat >>~/.ssh/known_hosts <<EOF
          ${self.nixosConfigurations.build01.config.environment.etc."ssh/ssh_known_hosts".text}
          EOF
        '';
      in
      {
        onPush.default.outputs.effects = hci-effects.runIf (config.repo.ref == "refs/heads/master") {
          darwin01 = hci-effects.runNixDarwin {
            ssh.destination = "customer@darwin01.nix-community.org";
            configuration = self.darwinConfigurations.darwin01;
            inherit secretsMap userSetupScript;
          };
          darwin02 = hci-effects.runNixDarwin {
            ssh.destination = "customer@darwin02.nix-community.org";
            configuration = self.darwinConfigurations.darwin02;
            inherit secretsMap userSetupScript;
          };
        };
      }
    );
}
