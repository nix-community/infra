{ pkgs, ... }:
## requires this secret in deployment.nix
#deployment.keys.gitlab-runner-registration = {
#  text = secrets.gitlab-runner-registration;
#  user = "gitlab-runner";
#  permissions = "0600";
#};
let
  gitlabModule = builtins.fetchTarball {
    url = "https://gitlab.com/arianvp/nixos-gitlab-runner/-/archive/9126927c701aa399bd1734e7e5230c3a0010c1b7/nixos-gitlab-runner-9126927c701aa399bd1734e7e5230c3a0010c1b7.tar.gz";
    sha256 = "1s0fy5ny2ygcfvx35xws8xz5ih4z4kdfqlq3r6byxpylw7r52fyi";
  };
in
{
  imports = [
    "${gitlabModule}/gitlab-runner.nix"
  ];

  services.gitlab-runner2.enable = true;
  # The module depends on gitlab-runner to have a "bin" output.
  services.gitlab-runner2.package = pkgs.gitlab-runner // {
    bin = pkgs.gitlab-runner;
  };
  services.gitlab-runner2.registrationConfigFile = "/run/keys/gitlab-runner-registration";
}
