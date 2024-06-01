{ self, ... }:
{
  perSystem =
    { system, ... }:
    {
      topology.modules = [
        {
          nodes = {
            darwin01 = {
              name = "darwin01";
              deviceType = "nixos";
            };
            darwin02 = {
              name = "darwin02";
              deviceType = "nixos";
            };
          };
        }
      ];
      packages.docs-topology = self.topology.${system}.config.output;
    };
}
