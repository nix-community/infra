{...}:

{

  virtualisation.docker = {
    enable = true;
    # Clean docker images periodically
    autoPrune = {
      enable = true;
      # Do not only remove "dangling" images (orphaned layers), also remove unused
      flags = [ "--all" ];
    };
  };

}
