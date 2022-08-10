# Add derivations to be built from the cache to this file
{ system ? builtins.currentSystem
, src ? { ref = null; }
}:
let
  self = builtins.getFlake (toString ./.);
  nixpkgs = self.inputs.nixpkgs;
  effects = self.inputs.hercules-ci-effects.lib.withPkgs nixpkgs.legacyPackages.x86_64-linux;
in
nixpkgs.lib.mapAttrs' (name: config: nixpkgs.lib.nameValuePair "nixos-${name}" config.config.system.build.toplevel) self.outputs.nixosConfigurations
