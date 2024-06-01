{ inputs, ... }:
let
  dnsConfig = {
    inherit (inputs.self) nixosConfigurations;
    extraConfig = import ./dns.nix;
  };
in
{
  perSystem = { pkgs, ... }:
    let
      generate = inputs.nixos-dns.utils.generate pkgs;
    in
    {
      packages = {
        octodns-zonefiles = generate.zoneFiles dnsConfig;
        octodns-config = generate.octodnsConfig {
          inherit dnsConfig;
          config = {
            providers = {
              cloudflare = {
                class = "octodns_cloudflare.CloudflareProvider";
                token = "env/CLOUDFLARE_API_TOKEN";
              };
            };
          };
          zones = {
            "nix-community.org." = inputs.nixos-dns.utils.octodns.generateZoneAttrs [ "cloudflare" ];
          };
        };
      };
      devShells = {
        octodns = with pkgs; mkShellNoCC {
          packages = [
            octodns
            octodns-providers.bind
            (callPackage ./octodns-cloudflare.nix { })
          ];
        };
      };
    };
}
