{
  hercules-ci.flake-update = {
    enable = true;
    createPullRequest = true;
    baseMerge.enable = true;
    baseMerge.method = "fast-forward";
    when = {
      hour = [ 0 ];
      minute = 0;
      # hack, onSchedule effect that never runs
      dayOfMonth = 32;
    };
  };
}
