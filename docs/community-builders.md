We provide machines as public builders for the nix community.

`x86_64-linux`

```
build-box.nix-community.org ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIElIQ54qAy7Dh63rBudYKdbzJHrrbrrMXLYl7Pkmk88H
```

`aarch64-linux`

```
aarch64-build-box.nix-community.org ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG9uyfhyli+BRtk64y+niqtb+sKquRGGZ87f4YRc8EE1
```

`aarch64-darwin`

```
darwin-build-box.nix-community.org ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKMHhlcn7fUpUuiOFeIhDqBzBNFsbNqq+NpzuGX3e6zv
```

[_Note: currently the darwin build box doesn't support FIDO keys._](https://github.com/nix-community/infra/issues/1007)

See [here](./infrastructure.md#community-builders) for details about the hardware.

### Access

We will grant access to well known members of the community, and people well known members in the community trust.

Add your username to [`nixos/community-builder/users.nix`](https://github.com/nix-community/infra/blob/master/modules/nixos/community-builder/users.nix) or [`darwin/community-builder/users.nix`](https://github.com/nix-community/infra/blob/master/modules/darwin/community-builder/users.nix).

Don't keep any important data in your home! We will regularly delete `$HOME` without notice.

### Notes on Security and Safety

**_TLDR:_** a trusted but malicious actor could hack your system through this builder. Do not use this builder for secret builds. Be careful what you use this system for. Do not trust the results. For a more nuanced understanding, read on.

For someone to use a server as a remote builder, they must be a `trusted-user` on the remote builder. `man nix.conf` has this to say about Trusted Users:

> User that have additional rights when connecting to the Nix daemon, such as the ability to specify additional binary caches, or to import unsigned NARs.
>
> Warning: The users listed here have the ability to compromise the security of a multi-user Nix store. For instance, they could install Trojan horses subsequently executed by other users. So you should consider carefully whether to add users to this list.

Nix's model of remote builders requires users to be able to directly import files in to the Nix store, and there is no guarantee what they import hasn't been maliciously modified.

1. **_DO NOT_** trust this builder for systems that contain private data or tools.

2. **_DO NOT_** trust this builder to make binary bootstrap tools, because we have to trust those bootstrap tools for a long time to not be compromised.

3. **_DO NOT_** trust this builder to make tools used to make binary bootstrap tools, because we have to trust those bootstrap tools for a long time to not be compromised.

IF YOU ARE: making binary bootstrap tools, please only use tools built on a system which have never been exposed to things built on these builders.

_This section is based on the notes ([1](https://github.com/NixOS/aarch64-build-box), [2](https://github.com/nix-community/darwin-build-box)) written by [@grahamc](https://github.com/grahamc) and [@winterqt](https://github.com/winterqt)._

### Using your NixOS home-manager configuration on the hosts

If you happen to have your NixOS & home-manager configurations intertwined but you'd like your familiar environment on our infrastructure you can evaluate `pkgs.writeShellScript "hm-activate" config.systemd.services.home-manager-<yourusername>.serviceConfig.ExecStart` from your NixOS configuration, and send this derivation to be realized remotely: (in case you aren't a Nix trusted user)

```console
# somehow get the .drv of the above expression into $path
$ nix copy --to ssh://build-box.nix-community.org --derivation $path
$ ssh build-box.nix-community.org
$ nix-store -r $path
$ $path
```

_(My [implementation](https://github.com/ckiee/nixfiles/blob/aac57f56e417e31f00fd495d8a30fb399ecbc19b/deploy/hm-only.nix#L10) of [this](https://github.com/ckiee/nixfiles/blob/aac57f56e417e31f00fd495d8a30fb399ecbc19b/bin/c#L92-L95) ~ckie)_
