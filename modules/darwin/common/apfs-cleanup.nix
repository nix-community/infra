{
  # https://github.com/NixOS/nixos-org-configurations/blob/71b3de5d1332eeb8fcb05549f4349a433c6935b7/macs/nix-darwin.nix#L79
  # https://github.com/ofborg/infrastructure/blob/188e976eb38bb9c5a27b94675555c5b534e76bc8/flake.nix#L26
  launchd.daemons.apfs-cleanup = {
    # for whatever reason, rosetta keeps garbage around until we run this command
    script = ''
      date
      /System/Library/Filesystems/apfs.fs/Contents/Resources/apfs.util -P -minsize 0 /System/Volumes/Data
    '';
    serviceConfig = {
      StartCalendarInterval = [
        {
          Hour = 2;
          Minute = 30;
        }
      ];
      StandardErrorPath = "/var/log/apfs-cleanup.log";
      StandardOutPath = "/var/log/apfs-cleanup.log";
    };
  };
}
