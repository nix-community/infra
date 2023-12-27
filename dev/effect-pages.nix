{
  hercules-ci.github-pages = {
    branch = "master";
  };

  perSystem =
    { config, ... }:
    {
      hercules-ci.github-pages.settings = {
        contents = config.packages.docs;
      };
    };
}
