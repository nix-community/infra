{ pkgs, ... }:

let
  gitlabModule = pkgs.fetchFromGitLab {
    owner = "arianvp";
    repo = "nixos-gitlab-runner";
    rev = "9126927c701aa399bd1734e7e5230c3a0010c1b7";
    sha256 = "1s0fy5ny2ygcfvx35xws8xz5ih4z4kdfqlq3r6byxpylw7r52fyi";
  };

in {
  imports = [
    "${gitlabModule}/gitlab-runner.nix"
  ];

  services.gitlab-runner2.enable = true;
  services.gitlab-runner2.registrationConfigFile = "/run/keys/gitlab-runner-registration";
}
