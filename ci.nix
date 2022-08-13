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
      ...
  }: effects.mkEffect (args // {
    secretsMap.ssh = "default-ssh";
    # This style of variable passing allows overrideAttrs and modification in
    # hooks like the userSetupScript.
    inherit hostname drv;
    effectScript = ''
      writeSSHKey ssh ~/.ssh/id_ed25519
      cat >>~/.ssh/known_hosts <<EOF
      build01.nix-community.org ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIElIQ54qAy7Dh63rBudYKdbzJHrrbrrMXLYl7Pkmk88H
      build02.nix-community.org ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMm3/o1HguyRL1z/nZxLBY9j/YUNXeNuDoiBLZAyt88Z
      build03.nix-community.org ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFiozp1A1+SUfJQPa5DZUQcVc6CZK2ZxL6FJtNdh+2TP
      build04.nix-community.org ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPU/gbREwVuI1p3ag1iG72jxl2/92yGl38c+TPOfFMH8
      EOF

      ${pkgs.openssh}/bin/ssh -i deploy-key root@"$hostname" "\$(nix-store -r $drv)/bin/switch-to-configuration switch"
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
