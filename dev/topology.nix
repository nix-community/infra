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
      packages.topology-output = self.topology.${system}.config.output;
    };
}
