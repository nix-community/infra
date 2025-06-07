{ inputs, ... }:
{
  imports = [
    ./gandi.nix
    ./postgresql.nix
    inputs.self.nixosModules.monitoring
    inputs.self.nixosModules.nginx
    # garage s3
    # for now just single node for terraform backend to replace terraform cloud
    # might be possible to adapt https://github.com/ipdxco/github-as-code to use a non-aws s3 backend?
  ];

  networking.useDHCP = true;
}
