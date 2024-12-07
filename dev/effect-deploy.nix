{ self, withSystem, ... }:
{
  herculesCI = herculesCI: {
    onPush.default.outputs.effects = withSystem "x86_64-linux" (
      { hci-effects, ... }:
      let
        darwin01 = self.darwinConfigurations.darwin01.config.system.build.toplevel.outPath;
        darwin02 = self.darwinConfigurations.darwin02.config.system.build.toplevel.outPath;
        secretsMap.ssh-deployment = "ssh-deployment";
        userSetupScript = "writeSSHKey ssh-deployment";
      in
      {
        darwin01 = hci-effects.runIf (herculesCI.config.repo.branch == "refs/pull/1059/merge") (
          hci-effects.mkEffect {
            inherit secretsMap userSetupScript;
            effectScript = ''
              ${hci-effects.ssh { destination = "customer@darwin01.nix-community.org"; } ''
                set -eux
                newProfile=$(nix-store --option narinfo-cache-negative-ttl 0 --realise ${darwin01})
                sudo -H nix-env --profile /nix/var/nix/profiles/system --set $newProfile
                $newProfile/sw/bin/darwin-rebuild activate
                set +x
              ''}
            '';
          }
        );
        darwin02 = hci-effects.runIf (herculesCI.config.repo.branch == "refs/pull/1059/merge") (
          hci-effects.mkEffect {
            inherit secretsMap userSetupScript;
            effectScript = ''
              ${hci-effects.ssh { destination = "customer@darwin02.nix-community.org"; } ''
                set -eux
                newProfile=$(nix-store --option narinfo-cache-negative-ttl 0 --realise ${darwin02})
                sudo -H nix-env --profile /nix/var/nix/profiles/system --set $newProfile
                $newProfile/sw/bin/darwin-rebuild activate
                set +x
              ''}
            '';
          }
        );
      }
    );
  };
}
