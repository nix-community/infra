{
  config,
  lib,
  withSystem,
  ...
}:
let
  inherit (config) defaultEffectSystem;

  commit = "devdoc: update repo list";

  buildable = effect: (effect.overrideAttrs { isEffect = false; }).inputDerivation;

  effect =
    hci-effects: gitRemote:
    hci-effects.flakeUpdate {
      inherit gitRemote;
      createPullRequest = true;
      pullRequestTitle = commit;
      baseMergeBranch = "master";
      baseMergeMethod = "reset";
      updateBranch = "update-repo-list";
      module.git.update.script = lib.mkForce ''
        gh api --paginate /orgs/nix-community/repos --jq '.[].html_url' | sort --ignore-case > devdoc/repo_list
        git add devdoc/repo_list
        git commit -m ${commit}
      '';
    };
in
{
  perSystem =
    { hci-effects, system, ... }:
    lib.optionalAttrs (system == defaultEffectSystem) {
      # this check ensures that the hercules-ci.flake-update and update-repo-list effects are buildable
      checks.on-schedule-pull-request-effect-is-buildable = buildable (
        effect hci-effects "https://fake-repo-for.checks.update-repo-list-effect-is-buildable"
      );
    };

  herculesCI = herculesCI: {
    onSchedule.update-repo-list = {
      outputs.effects = withSystem defaultEffectSystem (
        { hci-effects, ... }: {
          update-repo-list = effect hci-effects herculesCI.config.repo.remoteHttpUrl;
        }
      );
      when.hour = [ 2 ];
    };
  };
}
