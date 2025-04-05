{
  perSystem =
    { pkgs, ... }:
    {
      devShells.dnscontrol = pkgs.mkShellNoCC { packages = [ pkgs.dnscontrol ]; };
      packages.dnscontrol-check =
        pkgs.runCommand "dnscontrol-check"
          {
            buildInputs = [ pkgs.dnscontrol ];
            files = pkgs.lib.fileset.toSource rec {
              root = ../dnscontrol;
              fileset = pkgs.lib.fileset.unions [
                root
              ];
            };
          }
          ''
            cd $files
            dnscontrol check
            touch $out
          '';
    };
}
