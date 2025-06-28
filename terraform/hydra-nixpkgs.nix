let
  stable = "nixos-25.05-small";
  stable_previous = "nixos-24.11-small";

  base_jobsets = {
    bsd = {
      name = "bsd";
      description = "nixos-unstable-small bsd";
      nixpkgs_channel = "nixos-unstable-small";
      release_file = "hydra/bsd.nix";
      release_source = "https://github.com/nix-community/infra.git master";
      scheduling_shares = 1000;
      supported_systems = [ "x86_64-freebsd" ];
      staging_next = true;
    };
    cuda = {
      name = "cuda";
      description = "nixos-unstable-small cuda";
      nixpkgs_channel = "nixos-unstable-small";
      release_file = "pkgs/top-level/release-cuda.nix";
      scheduling_shares = 6000;
      supported_systems = [ "x86_64-linux" ];
      stable = true;
    };
    rocm = {
      name = "rocm";
      description = "nixos-unstable-small rocm";
      nixpkgs_channel = "nixos-unstable-small";
      release_file = "pkgs/top-level/release-cuda.nix";
      scheduling_shares = 6000;
      supported_systems = [ "x86_64-linux" ];
      extra_inputs = [
        {
          name = "variant";
          type = "string";
          value = "rocm";
        }
      ];
    };
    unfree_redist = {
      name = "unfree-redist";
      description = "nixos-unstable-small unfree+redistributable";
      nixpkgs_channel = "nixos-unstable-small";
      release_file = "pkgs/top-level/release-unfree-redistributable.nix";
      scheduling_shares = 5000;
      supported_systems = [
        "aarch64-linux"
        "x86_64-linux"
      ];
      stable = true;
    };
    unfree_redist_darwin = {
      name = "unfree-redist-darwin";
      description = "nixpkgs-unstable darwin unfree+redistributable";
      nixpkgs_channel = "nixpkgs-unstable";
      release_file = "pkgs/top-level/release-unfree-redistributable.nix";
      scheduling_shares = 5000;
      supported_systems = [
        "aarch64-darwin"
        "x86_64-darwin"
      ];
    };
    unfree_redist_full = {
      name = "unfree-redist-full";
      description = "nixos-unstable unfree+redistributable full";
      nixpkgs_channel = "nixos-unstable";
      release_file = "pkgs/top-level/release-unfree-redistributable.nix";
      scheduling_shares = 1000;
      supported_systems = [ "x86_64-linux" ];
      extra_inputs = [
        {
          name = "full";
          type = "boolean";
          value = "true";
        }
      ];
    };
  };

  generate_jobset_variants =
    name: job:
    let
      variants = builtins.filter (x: x != null) [
        (
          if job ? stable && job.stable then
            {
              name = "${name}_stable";
              value = job // {
                name = builtins.replaceStrings [ "_" ] [ "-" ] "${name}-stable";
                description = builtins.replaceStrings [ job.nixpkgs_channel ] [ stable ] job.description;
                nixpkgs_channel = stable;
              };
            }
          else
            null
        )
        (
          if job ? stable && job.stable then
            {
              name = "${name}_stable_previous";
              value = job // {
                name = builtins.replaceStrings [ "_" ] [ "-" ] "${name}-stable-previous";
                description = builtins.replaceStrings [ job.nixpkgs_channel ] [ stable_previous ] job.description;
                nixpkgs_channel = stable_previous;
              };
            }
          else
            null
        )
        (
          if job ? staging_next && job.staging_next then
            {
              name = "${name}_staging_next";
              value = job // {
                name = builtins.replaceStrings [ "_" ] [ "-" ] "${name}-staging-next";
                description = builtins.replaceStrings [ job.nixpkgs_channel ] [ "staging-next" ] job.description;
                nixpkgs_channel = "staging-next";
              };
            }
          else
            null
        )
      ];
    in
    builtins.listToAttrs variants;

  jobsets =
    base_jobsets
    // builtins.foldl' (o: name: o // generate_jobset_variants name base_jobsets.${name}) { } (
      builtins.attrNames base_jobsets
    );

  generate_inputs =
    o:
    let
      base_inputs = [
        {
          name = "nixpkgs";
          type = "git";
          value = "https://github.com/NixOS/nixpkgs.git ${o.nixpkgs_channel}";
        }
        {
          name = "officialRelease";
          type = "boolean";
          value = "false";
        }
        {
          name = "supportedSystems";
          type = "nix";
          value = ''[ ${builtins.concatStringsSep " " (map (s: "\"${s}\"") o.supported_systems)} ]'';
        }
      ];

      extra_inputs = o.extra_inputs or [ ];

      release_source =
        if o ? release_source then
          [
            {
              name = "release_source";
              type = "git";
              value = o.release_source;
            }
          ]
        else
          [ ];
    in
    map (input: input // { notify_committers = false; }) (
      base_inputs ++ extra_inputs ++ release_source
    );
in
rec {
  resource = {
    hydra_jobset = builtins.mapAttrs (name: o: {
      inherit (o)
        description
        name
        scheduling_shares
        ;
      check_interval = 1800;
      email_notifications = false;
      email_override = "";
      keep_evaluations = 1;
      project = resource.hydra_project.nixpkgs.name;
      state = "enabled";
      type = "legacy";
      visible = true;
      nix_expression = {
        file = o.release_file;
        input = if o ? release_source then "release_source" else "nixpkgs";
      };
      lifecycle = {
        ignore_changes = [ "state" ];
      };
      input = generate_inputs o;
    }) jobsets;

    hydra_project = {
      nixpkgs = {
        name = "nixpkgs";
        display_name = "nixpkgs";
        description = "you know what this is";
        homepage = "https://github.com/NixOS/nixpkgs";
        owner = "admin";
        enabled = true;
        visible = true;
      };
    };
  };
}
