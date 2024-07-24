{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  hostInfo = pkgs.writeShellScript "host-info" ''
    nix_version="$(${config.nix.package}/bin/nix store ping --store daemon --json | ${pkgs.jq}/bin/jq -r '.version')"
    case "$(uname -s)" in
    Darwin)
      os_version="$(/usr/bin/sw_vers --productVersion)_$(/usr/bin/sw_vers --buildVersion)"
      ;;
    Linux)
      os_version="$(uname -r)"
      ;;
    esac
    system="$(${config.nix.package}/bin/nix eval --impure --raw --expr 'builtins.currentSystem')"
    echo "host,nix_version=$nix_version,os_version=$os_version,system=$system info=1"
  '';
in
{
  environment.etc =
    let
      inputsWithDate = lib.filterAttrs (_: input: input ? lastModified) inputs.self.inputs;
      flakeAttrs =
        input:
        (lib.mapAttrsToList (n: v: ''${n}="${v}"'') (
          lib.filterAttrs (_: v: (builtins.typeOf v) == "string") input
        ));
      lastModified =
        name: input:
        ''flake_input_last_modified{input="${name}",${lib.concatStringsSep "," (flakeAttrs input)}} ${toString input.lastModified}'';
    in
    {
      "flake-inputs.prom" = {
        text = builtins.unsafeDiscardStringContext ''
          # HELP flake_registry_last_modified Last modification date of flake input in unixtime
          # TYPE flake_input_last_modified gauge
          ${lib.concatStringsSep "\n" (lib.mapAttrsToList lastModified inputsWithDate)}
        '';
      };
    };

  services.telegraf.extraConfig.inputs = {
    exec = [
      {
        commands = [ hostInfo ];
        data_format = "influx";
      }
    ];
    file = [
      {
        data_format = "prometheus";
        files = [ "/etc/flake-inputs.prom" ];
      }
    ];
    prometheus = {
      metric_version = 2;
    };
  };
}
