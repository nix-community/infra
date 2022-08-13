# Add derivations to be built from the cache to this file
{ system ? builtins.currentSystem
, src ? { ref = null; }
}:
let
  self = builtins.getFlake (toString ./.);
  nixpkgs = self.inputs.nixpkgs;
  effects = self.inputs.hercules-ci-effects.lib.withPkgs nixpkgs.legacyPackages.x86_64-linux;

  deployNixOS = args@{
    hostname,
    drv,
      ...
  }: effects.mkEffect (args // {
    secretsMap.deploy = "default-deploy";
    # This style of variable passing allows overrideAttrs and modification in
    # hooks like the userSetupScript.
    inherit hostname drv;
    effectScript = ''
      umask 077 # so ssh does not complain about key permissions
      readSecretString deploy .sshKey > deploy-key
      ssh -i deploy-key root@"$hostname" "$(nix-store -r $drv)/bin/switch-to-configuration $action"
    '';
  });
in
(nixpkgs.lib.mapAttrs' (name: config: nixpkgs.lib.nameValuePair "nixos-${name}" config.config.system.build.toplevel) self.outputs.nixosConfigurations) // {
 build01 = deployNixOS {
    hostname = "build01.nix-community.org";
    # using the drv path here avoids downloading the closure on the deploying machine
    drv = builtins.unsafeDiscardStringContext self.outputs.nixosConfigurations.nix-community-build01.config.system.build.toplevel.drvPath;
  };
}
