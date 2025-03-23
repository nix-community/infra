{
  hercules-ci.flake-update = {
    enable = true;
    createPullRequest = true;
    when = {
      hour = [ 2 ];
      dayOfWeek = [
        "Mon"
        "Thu"
      ];
    };
  };
}
