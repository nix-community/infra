# Add derivations to be built from the cache to this file
{ system ? builtins.currentSystem
, src ? { ref = null; }
}:
let
  pkgs = import ./nix { inherit system; };

  importNixOS = configuration: system:
    (import "${toString pkgs.path}/nixos") {
      inherit configuration system;
    };

  deploy = machine: pkgs.effects.runIf (src.ref == "refs/heads/master") (pkgs.effects.runCachixDeploy {
    deploy.agents = {
      ${machine.config.networking.hostName} = machine.config.system.build.toplevel;
    };
  });
in
pkgs.nix-community-infra // rec {
  build01 = importNixOS ./build01/configuration.nix "x86_64-linux";
  build01-system = build01.system;
  build01-deploy = deploy build01;

  build02 = importNixOS ./build02/configuration.nix "x86_64-linux";
  build02-system = build02.system;
  build02-deploy = deploy build02;

  build03 = importNixOS ./build03/configuration.nix "x86_64-linux";
  build03-system = build03.system;
  build03-deploy = deploy build03;

  build04 = importNixOS ./build04/configuration.nix "aarch64-linux";
  build04-system = build04.system;
  build04-deploy = deploy build04;
}
