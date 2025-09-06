## Onboarding a new nix-community admin

- Add them to the [list of administrators](../docs/administrators.md)

- Add their user and ssh key to [users](../users) as member of the `trusted` and `wheel` groups.

  - `wheel` will give them access to the terraform state storage.

- Add their age key to [sops.json](../sops.json) and run `inv update-sops-files`.

- Add their user to the list of `admins` in [modules/nixos/buildbot.nix](../modules/nixos/buildbot.nix).

- Add their user to the list of `hydra-github-users` in [modules/nixos/hydra.nix](../modules/nixos/hydra.nix).

- Make them a `owner` of the [nix-community GitHub organisation](https://github.com/nix-community) and a member of the [nix-community GitHub `admin` team](https://github.com/orgs/nix-community/teams/admin/members).

- Make them an `admin` in these Matrix rooms:

  - https://matrix.to/#/#nix-community:nixos.org
  - https://matrix.to/#/#nix-community-monitoring:matrix.org

- Make them an `owner` on [Gandi](https://admin.gandi.net/) and add them to the email forwarding for the `admin@nix-community.org` address.

  - Organisations -> Nix Community -> Teams -> Owner
  - Domain -> nix-community.org -> Email -> Forwarding address -> Forwards to

- They will also need to be added manually to these services:

  - [Cachix](https://app.cachix.org/organization/nix-community/settings)
  - [Cloudflare](https://dash.cloudflare.com/e4a2db52c495db230973c839a0699ae1/members)
  - [GitLab](https://gitlab.com/groups/nix-community/-/group_members)
  - [Hetzner Robot](https://robot.hetzner.com/key/index)
  - [Namespace](https://cloud.namespace.so/4l6g3pb71m64u/settings/users)
  - [OpenCollective](https://opencollective.com/nix-community/admin/team)
