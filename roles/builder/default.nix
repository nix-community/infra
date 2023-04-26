{ pkgs, ... }: {
  imports = [
    ./packages.nix
    ./users.nix
  ];

  programs.fish.enable = true;
  # disable generated completion
  environment.etc."fish/generated_completions".text = pkgs.lib.mkForce "";

  programs.zsh.enable = true;
}
