{
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
