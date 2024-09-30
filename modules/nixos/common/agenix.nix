{ inputs, ... }:
{
  imports = [
    inputs.agenix.nixosModules.age
  ];
}
