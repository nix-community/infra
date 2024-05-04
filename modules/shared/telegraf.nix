{ inputs, lib, ... }:
{
  environment.etc =
    let
      inputsWithDate = lib.filterAttrs (_: input: input ? lastModified) inputs.self.inputs;
      flakeAttrs = input: (lib.mapAttrsToList (n: v: ''${n}="${v}"'')
        (lib.filterAttrs (_: v: (builtins.typeOf v) == "string") input));
      lastModified = name: input: ''
        flake_input_last_modified{input="${name}",${lib.concatStringsSep "," (flakeAttrs input)}} ${toString input.lastModified}'';
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
