{ lib, ... }:
{
  system.activationScripts.postActivation.text = lib.mkBefore ''
    if ! pgrep -q oahd; then
      echo installing rosetta... >&2
      softwareupdate --install-rosetta --agree-to-license
    fi
  '';

  system.defaults.CustomSystemPreferences = {
    # check daily, install critical updates, disable macos updates
    "/Library/Preferences/com.apple.SoftwareUpdate" = {
      AutomaticallyInstallAppUpdates = false;
      AutomaticallyInstallMacOSUpdates = false;
      AutomaticCheckEnabled = true;
      AutomaticDownload = false;
      ConfigDataInstall = true;
      CriticalUpdateInstall = true;
      restrict-software-update-require-admin-to-install = true;
      ScheduleFrequency = 1;
    };
  };
}
