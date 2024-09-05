{ inputs, pkgs, ... }:
{
  imports = [
    "${inputs.self}/modules/shared/community-builder.nix"
    inputs.nix-index-database.darwinModules.nix-index
    ./users.nix
  ];

  environment.systemPackages = [
    pkgs.vim
  ];
}
