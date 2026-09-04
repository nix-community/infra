{
  config,
  lib,
  withSystem,
  ...
}:
let
  commit = "devdoc: update repo list";
in
{
  herculesCI = herculesCI: {
    onSchedule.update-repo-list = {
      outputs.effects = withSystem config.defaultEffectSystem (
        { hci-effects, ... }: {
          update-repo-list = hci-effects.flakeUpdate {
            gitRemote = herculesCI.config.repo.remoteHttpUrl;
            createPullRequest = true;
            pullRequestTitle = commit;
            baseMergeBranch = "master";
            baseMergeMethod = "reset";
            updateBranch = "update-repo-list";
            module.git.update.script = lib.mkForce ''
              gh api --paginate /orgs/nix-community/repos --jq '.[].html_url' | sort --ignore-case > devdoc/repo_list
              git add devdoc/repo_list
              if git diff --cached --quiet; then
                echo "Nothing to commit."
              else
                git commit -m "${commit}"
              fi
            '';
          };
        }
      );
      when.hour = [ 2 ];
    };
  };
}
