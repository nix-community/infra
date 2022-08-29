# Add derivations to be built from the cache to this file
{ system ? builtins.currentSystem
, src ? { ref = null; }
}:
let
  self = builtins.getFlake (toString ./.);
  nixpkgs = self.inputs.nixpkgs;
  pkgs = nixpkgs.legacyPackages.x86_64-linux;
  effects = self.inputs.hercules-ci-effects.lib.withPkgs nixpkgs.legacyPackages.x86_64-linux;

  deployNixOS = args@{
    hostname,
    drv,
    knownHosts,
      ...
  }: effects.runIf (src.ref == "refs/heads/master") (effects.mkEffect (args // {
    secretsMap.ssh = "default-ssh";
    # This style of variable passing allows overrideAttrs and modification in
    # hooks like the userSetupScript.
    inherit hostname drv knownHosts;
    effectScript = ''
      export PATH=$PATH:${pkgs.openssh}/bin
      writeSSHKey ssh ~/.ssh/id_ed25519
      echo "$knownHosts" >>~/.ssh/known_hosts
      ssh root@"$hostname" "\$(nix-store -r $drv)/bin/switch-to-configuration switch"
    '';
  }));
  stripDomain = name: nixpkgs.lib.head (builtins.match "(.*).nix-community.org" name);
  deployNixOS' = name: config: nixpkgs.lib.nameValuePair "deploy-${stripDomain name}" (deployNixOS {
    hostname = config.config.networking.fqdn;
    knownHosts = config.config.environment.etc."ssh/ssh_known_hosts".text;
    drv = builtins.unsafeDiscardStringContext config.config.system.build.toplevel.drvPath;
  });
in
(nixpkgs.lib.mapAttrs' (name: config: nixpkgs.lib.nameValuePair "nixos-${stripDomain name}" config.config.system.build.toplevel) self.outputs.nixosConfigurations) //
(nixpkgs.lib.mapAttrs' deployNixOS' self.outputs.nixosConfigurations)
