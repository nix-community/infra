{ inputs, pkgs, ... }:
{
  imports = [
    "${inputs.self}/modules/shared/community-builder.nix"
    inputs.nix-index-database.nixosModules.nix-index
    ./users.nix
  ];

  environment.systemPackages = [
    # terminfo packages
    pkgs.foot.terminfo
    pkgs.kitty.terminfo
    pkgs.termite.terminfo
    pkgs.wezterm.terminfo
  ];

  programs.mosh = {
    enable = true;
    withUtempter = false;
  };

  programs.fish.enable = true;
  # disable generated completion
  environment.etc."fish/generated_completions".text = pkgs.lib.mkForce "";
}
