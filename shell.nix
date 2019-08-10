let

  channelUrl = "https://github.com/NixOS/nixpkgs-channels/archive/nixos-unstable.tar.gz";
  nixpkgs = builtins.fetchTarball channelUrl;
  pkgs = import nixpkgs {};

in pkgs.mkShell {

  NIX_PATH="nixpkgs=${nixpkgs}";

  buildInputs = [
    pkgs.git-crypt
    pkgs.nixops
  ];

}
