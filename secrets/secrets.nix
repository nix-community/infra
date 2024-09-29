let
  adisbladis = builtins.readFile ../users/keys/adisbladis;
  mic92 = builtins.readFile ../users/keys/mic92;
  ryantm = builtins.readFile ../users/keys/ryantm;
  zimbatm = builtins.readFile ../users/keys/zimbatm;
  zowoq = builtins.readFile ../users/keys/zowoq;

  users = [
    adisbladis
    mic92
    ryantm
    zimbatm
    zowoq
  ];

  inherit ((import ../modules/shared/known-hosts.nix).programs.ssh) knownHosts;

  build02 = knownHosts.build02.publicKey;
  build03 = knownHosts.build03.publicKey;
  build04 = knownHosts.build04.publicKey;
  darwin02 = knownHosts.darwin02.publicKey;
  web02 = knownHosts.web02.publicKey;
in
{
  "buildbot-github-oauth-secret.age".publicKeys = users ++ [ build03 ];
  "buildbot-github-webhook-secret.age".publicKeys = users ++ [ build03 ];
  "buildbot-nix-worker-password.age".publicKeys = users ++ [ build03 ];
  "buildbot-nix-workers.age".publicKeys = users ++ [ build03 ];
  "cachix-auth-token.age".publicKeys = users ++ [ build03 ];
  "hercules-binary-caches.age".publicKeys = users ++ [
    build03
    build04
    darwin02
  ];
  "hercules-cluster-join-token.age".publicKeys = users ++ [
    build03
    build04
    darwin02
  ];
  "hercules-secrets.age".publicKeys = users ++ [
    build03
    build04
  ]; # hercules-secrets are only needed on linux
  "hetzner-borgbackup-ssh.age".publicKeys = users ++ [
    build02
    build03
  ];
  "hydra-admin-password.age".publicKeys = users ++ [ build03 ];
  "hydra-users.age".publicKeys = users ++ [ build03 ];
  "id_buildfarm.age".publicKeys = users ++ [ build03 ];
  "nginx-basic-auth-file.age".publicKeys = users ++ [ web02 ];
  "nginx-basic-auth-password.age".publicKeys = users ++ [ web02 ];
  "nix-community-matrix-bot-token.age".publicKeys = users ++ [ web02 ];
  "nixpkgs-update-github-r-ryantm-key.age".publicKeys = users ++ [ build02 ];
  "nixpkgs-update-github-r-ryantm-token.age".publicKeys = users ++ [ build02 ];
  "nixpkgs-update-github-token-with-username.age".publicKeys = users ++ [ build02 ];
  "nixpkgs-update-nix-community-cachix.age".publicKeys = users ++ [ build02 ];
  "nur-update-github-token.age".publicKeys = users ++ [ build03 ];
}
