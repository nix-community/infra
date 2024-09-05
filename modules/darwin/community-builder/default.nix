{ inputs, pkgs, ... }:
{
  imports = [
    "${inputs.self}/modules/shared/community-builder.nix"
    ./users.nix
  ];

  environment.systemPackages = [
    pkgs.vim
  ];
}
