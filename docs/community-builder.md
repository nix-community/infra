`build01.nix-community.org`

We provide an `x86_64-linux` build machine as a public remote builder for the nix community, this machine also has an `aarch64-linux` machine configured as its own remote builder.

#### Access

If you want access read the security guide lines on [aarch64-build-box](https://github.com/nix-community/aarch64-build-box). Than add your username to [`builder/users.nix`](https://github.com/nix-community/infra/blob/master/modules/nixos/community-builder/users.nix). Don't keep any important data in your home! We will regularly delete `/home` without further notice.

#### Using your NixOS home-manager configuration on the hosts

If you happen to have your NixOS & home-manager configurations intertwined but you'd like your familiar environment on our infrastructure you can evaluate `pkgs.writeShellScript "hm-activate" config.systemd.services.home-manager-<yourusername>.serviceConfig.ExecStart` from your NixOS configuration, and send this derivation to be realized remotely: (in case you aren't a Nix trusted user)

```console
# somehow get the .drv of the above expression into $path
$ nix copy --to ssh://build01.nix-community.org --derivation $path
$ ssh build01.nix-community.org
$ nix-store -r $path
$ $path
```

_(My [implementation](https://github.com/ckiee/nixfiles/blob/aac57f56e417e31f00fd495d8a30fb399ecbc19b/deploy/hm-only.nix#L10) of [this](https://github.com/ckiee/nixfiles/blob/aac57f56e417e31f00fd495d8a30fb399ecbc19b/bin/c#L92-L95) ~ckie)_
