# https://github.com/NixOS/hydra/blob/6889b5a3f0f0826c8bd0049de02665c2845254ae/nixos-modules/builder-module.nix
{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.services.hydra-queue-builder-dev;
  user = "hydra-queue-builder";

  format = pkgs.formats.toml { };
in
{
  options = {
    services.hydra-queue-builder-dev = {
      enable = lib.mkEnableOption "QueueBuilder";

      queueRunnerAddr = lib.mkOption {
        description = "Queue Runner address to the grpc server";
        type = lib.types.singleLineStr;
      };

      settings = lib.mkOption {
        description = ''
          Settings for the builder, written to `/etc/hydra/builder.toml`.

          Every service in Rust in hydra has its own separate TOML configuration file,
          with just the settings it needs.
        '';
        type = lib.types.submodule {
          options = {
            pingInterval = lib.mkOption {
              description = "Interval in which pings are send to the runner";
              type = lib.types.ints.positive;
              default = 10;
            };

            speedFactor = lib.mkOption {
              description = "Additional Speed factor for this machine";
              type = lib.types.oneOf [
                lib.types.ints.positive
                lib.types.float
              ];
              default = 1;
            };

            maxJobs = lib.mkOption {
              description = "Maximum allowed of jobs. This only is used if the queue runner uses this metrics for determining free machines.";
              type = lib.types.ints.positive;
              default = 4;
            };

            buildCores = lib.mkOption {
              description = "Cores made available to each build (NIX_BUILD_CORES). 0 means use all available cores.";
              type = lib.types.ints.unsigned;
              default = config.nix.settings.cores;
              defaultText = lib.literalExpression "config.nix.settings.cores";
            };

            buildDirAvailThreshold = lib.mkOption {
              description = "Threshold in percent for nix build dir before jobs are no longer scheduled on the machine";
              type = lib.types.float;
              default = 10.0;
            };

            storeAvailThreshold = lib.mkOption {
              description = "Threshold in percent for /nix/store before jobs are no longer scheduled on the machine";
              type = lib.types.float;
              default = 10.0;
            };

            load1Threshold = lib.mkOption {
              description = "Maximum Load1 threshold before we stop scheduling jobs on that node. Only used if PSI is not available.";
              type = lib.types.float;
              default = 8.0;
            };

            cpuPsiThreshold = lib.mkOption {
              description = "Maximum CPU PSI in the last 10s before we stop scheduling jobs on that node";
              type = lib.types.float;
              default = 75.0;
            };

            memPsiThreshold = lib.mkOption {
              description = "Maximum Memory PSI in the last 10s before we stop scheduling jobs on that node";
              type = lib.types.float;
              default = 80.0;
            };

            ioPsiThreshold = lib.mkOption {
              description = "Maximum IO PSI in the last 10s before we stop scheduling jobs on that node. If null then this pressure check is disabled.";
              type = lib.types.nullOr lib.types.float;
              default = null;
            };

            systems = lib.mkOption {
              description = "List of supported systems. If null, system and extra-platforms are read from nix; an empty list means none.";
              type = lib.types.nullOr (lib.types.listOf lib.types.singleLineStr);
              default = null;
            };

            supportedFeatures = lib.mkOption {
              description = "Supported features for the builder. If null, system features are read from nix; an empty list means none.";
              type = lib.types.nullOr (lib.types.listOf lib.types.singleLineStr);
              default = null;
            };

            mandatoryFeatures = lib.mkOption {
              description = "Mandatory features for the builder.";
              type = lib.types.listOf lib.types.singleLineStr;
              default = [ ];
            };

            useSubstitutes = lib.mkOption {
              description = "Use substitution for paths";
              type = lib.types.bool;
              default = true;
            };
          };
        };
        default = { };
      };

      authorizationFile = lib.mkOption {
        description = "Path to token authorization file if token auth should be used.";
        type = lib.types.nullOr lib.types.path;
        default = null;
      };

      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.hydraPackages.hydra-builder;
        defaultText = lib.literalExpression "pkgs.hydraPackages.hydra-builder";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    init.services.hydra-queue-builder-dev = {
      description = "Hydra Queue Builder main service";
      startType = "foreground";
      dependencies = [ "NETWORKING" ];
      inherit user;

      path = [ config.nix.package ];

      startCommand = [
        "${cfg.package}/bin/hydra-builder"
        "--gateway-endpoint"
        cfg.queueRunnerAddr
        "--config-path"
        "/etc/hydra/builder.toml"
      ]
      ++ lib.optionals (cfg.authorizationFile != null) [
        "--authorization-file"
        cfg.authorizationFile
      ];
    };

    environment.etc."hydra/builder.toml".source = format.generate "builder.toml" (
      lib.filterAttrsRecursive (_: v: v != null) cfg.settings
    );

    systemd.tmpfiles.rules = [
      "d /nix/var/nix/gcroots/per-user/${user} 0755 ${user} hydra -"
    ];

    nix = {
      settings = {
        extra-trusted-users = [ user ];
        extra-experimental-features = [ "nix-command" ];
      };
    };

    users = {
      groups.hydra = { };
      users.${user} = {
        group = "hydra";
        home = "/var/lib/hydra-queue-builder";
        isSystemUser = true;
      };
    };
  };
}
