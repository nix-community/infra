{
  # match buildbot timeouts
  # https://github.com/nix-community/buildbot-nix/blob/85c0b246cc96cc244e4d9889a97c4991c4593dc3/buildbot_nix/__init__.py#L1008

  # causes problems with cgroups: https://github.com/nix-community/infra/issues/1459#issuecomment-2507146996
  nix.settings.max-silent-time = toString (60 * 20 * 3); # 3x buildbot

  nix.settings.timeout = toString (60 * 60 * 3);
}
