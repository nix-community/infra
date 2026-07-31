{ config, ... }:
{
  nix.settings.cores = config.nix.settings.max-jobs / 4;

  # match nixbot timeouts
  # https://github.com/Mic92/nixbot/blob/6764a0ef1c704b6db339f19d81cb5642a2508dff/nixosModules/nixbot.nix#L264

  # causes problems with cgroups: https://github.com/nix-community/infra/issues/1459#issuecomment-2507146996
  nix.settings.max-silent-time = toString (60 * 20 * 3); # 3x nixbot

  nix.settings.timeout = toString (60 * 60 * 3);
}
