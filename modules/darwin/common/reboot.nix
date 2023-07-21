{
  # reboot every sunday between 00:00 and 06:00
  launchd.daemons.reboot = {
    command = ''/sbin/shutdown -r "+$(( $RANDOM % ( 6 * 60 ) ))"'';
    serviceConfig.StartCalendarInterval = [
      {
        Hour = 0;
        Minute = 0;
        Weekday = 0;
      }
    ];
  };
}
