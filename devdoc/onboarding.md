## Onboarding a new nix-community admin

- Add them to the [list of administrators](../docs/administrators.md)

- Add their user and ssh key to [users](../users) as member of the `trusted` and `wheel` groups.

- Add their user to [secrets/secrets.nix](../secrets/secrets.nix) and run `inv update-agenix-files`.

- Add their age key to [.sops.yaml](../.sops.yaml), update the `creation_rules` and run `inv update-sops-files`.

- Add their email in [terraform/locals.tf](../terraform/locals.tf), this will give them access to:

  - [Cloudflare](https://dash.cloudflare.com/login)
  - [Terraform Cloud](https://app.terraform.io)

- Add their user to the list of `admins` in [modules/nixos/buildbot.nix](../modules/nixos/buildbot.nix).

- Make them a `owner` of the [nix-community GitHub organisation](https://github.com/nix-community) and a member of the [nix-community GitHub `admin` team](https://github.com/orgs/nix-community/teams/admin/members).

  - `owner` will give them admin access to [Hercules CI](https://hercules-ci.com/github/nix-community).

- Make them an `admin` in these Matrix rooms:

  - https://matrix.to/#/#nix-community:nixos.org
  - https://matrix.to/#/#nix-community-monitoring:matrix.org

- Make them an `owner` on [Gandi](https://admin.gandi.net/) and add them to the email forwarding for the `admin@nix-community.org` address.

  - Organisations -> Nix Community -> Teams -> Owner
  - Domain -> nix-community.org -> Email -> Forwarding address -> Forwards to

- They will also need to be added manually to these services:

  - [Cachix](https://app.cachix.org/organization/nix-community/settings)
  - [GitLab](https://gitlab.com/groups/nix-community/-/group_members)
  - [Hetzner Robot](https://robot.hetzner.com/key/index)
  - [OpenCollective](https://opencollective.com/nix-community/admin/team)
