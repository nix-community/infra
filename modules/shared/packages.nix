{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    dix
    gdu
    nix-diff
    nix-output-monitor
    nix-tree
  ];
}
