{ self, ... }:
{
  perSystem =
    { config, pkgs, ... }:
    {
      devShells.zensical = pkgs.mkShellNoCC { inputsFrom = [ config.packages.docs ]; };
      packages = {
        docs =
          pkgs.runCommand "docs"
            {
              buildInputs = [
                pkgs.zensical
              ];
              files = pkgs.lib.fileset.toSource {
                root = ../.;
                fileset = pkgs.lib.fileset.unions [
                  ../docs
                  ../mkdocs.yml
                ];
              };
            }
            # `zensical build --strict`: https://github.com/zensical/backlog/issues/72
            ''
              cp --no-preserve=mode -rT $files .
              cp --no-preserve=mode ${config.packages.docs-json}/*.json docs
              zensical build
              mkdir -p $out
              cp -rT site $out
            '';
        docs-linkcheck = pkgs.testers.lycheeLinkCheck rec {
          extraConfig = {
            include_mail = true;
            include_verbatim = true;
            index_files = [ "index.html" ];
            root_dir = site;
          };
          remap = {
            "https://nix-community.org" = site;
          };
          site = config.packages.docs;
        };
        docs-json =
          pkgs.runCommand "docs-json"
            {
              buildInputs = [ pkgs.jq ];
              hosts = pkgs.writeText "hosts.json" (
                builtins.toJSON (
                  pkgs.lib.mapAttrs (_: x: {
                    experimental-features = x.config.nix.settings.experimental-features or [ ];
                    extra-platforms = x.config.nix.settings.extra-platforms or [ ];
                    system-features = x.config.nix.settings.system-features or [ ];
                    inherit (x.pkgs.stdenv.hostPlatform) system;
                    inherit (x.config.nix.settings) sandbox;
                  }) (self.darwinConfigurations // self.nixosConfigurations)
                )
              );
            }
            ''
              mkdir -p $out
              for host in $(jq -r 'keys[]' $hosts); do
                jq --arg host "$host" \
                  '.[$host] | walk(if type == "array" then sort else . end)' \
                  --sort-keys < $hosts > $out/$host.json
              done
            '';
      };
    };
}
