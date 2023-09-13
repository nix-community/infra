{
  # cachix deploy secrets are installed manually from ./secrets.yaml
  # https://github.com/LnL7/nix-darwin/blob/master/modules/services/cachix-agent.nix
  services.cachix-agent.enable = true;
}
