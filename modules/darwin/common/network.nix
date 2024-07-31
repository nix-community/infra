{ config, lib, ... }:
{
  options.nixCommunity.darwin.ipv6 = lib.mkOption {
    type = lib.types.singleLineStr;
    default = null;
    description = ''
      <address> <prefixlength> <router>
    '';
  };

  config = {
    # disable application layer firewall, telegraf needs an incoming connection
    system.defaults.alf.globalstate = 0;

    # Make sure to disable netbios on activation
    system.activationScripts.postActivation.text = lib.mkBefore ''
      echo disabling netbios... >&2
      launchctl disable system/netbiosd
      launchctl unload -w /System/Library/LaunchDaemons/com.apple.netbiosd.plist 2>/dev/null || true
      echo setting ipv6... >&2
      networksetup -setv6manual Ethernet ${config.nixCommunity.darwin.ipv6}
    '';
  };
}
