{ self, withSystem, ... }:
{
  herculesCI = { config, ... }:
    withSystem "x86_64-linux" ({ hci-effects, ... }:
      {
        onPush.default.outputs.effects = hci-effects.runIf (config.repo.ref == "refs/heads/master")
          {
            darwin02 = hci-effects.runNixDarwin {
              ssh.destination = "hetzner@darwin02.nix-community.org";
              configuration = self.darwinConfigurations.darwin02;
              buildOnDestination = true;
              secretsMap.ssh-deployment = "ssh-deployment";
              userSetupScript = ''
                writeSSHKey ssh-deployment
                cat >>~/.ssh/known_hosts <<EOF
                darwin02.nix-community.org ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICJqwpMUEl1/iwrBakeDb1rlheXlE5mfDLICVz8w6yi6
                EOF
              '';
            };
            darwin03 = hci-effects.runNixDarwin {
              ssh.destination = "hetzner@darwin03.nix-community.org";
              configuration = self.darwinConfigurations.darwin03;
              buildOnDestination = true;
              secretsMap.ssh-deployment = "ssh-deployment";
              userSetupScript = ''
                writeSSHKey ssh-deployment
                cat >>~/.ssh/known_hosts <<EOF
                darwin03.nix-community.org ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKX7W1ztzAtVXT+NBMITU+JLXcIE5HTEOd7Q3fQNu80S
                EOF
              '';
            };
          };
      }
    );
}
