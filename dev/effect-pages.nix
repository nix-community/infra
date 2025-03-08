{
  hercules-ci.github-pages = {
    branch = "master";
  };

  perSystem =
    { config, ... }:
    {
      hercules-ci.github-pages.settings = {
        # automatic token generation by buildbot github app ??
        # secretsMap.token = "token-for-pages";
        contents = config.packages.docs;
      };
    };
}
