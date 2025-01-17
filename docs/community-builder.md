We provide machines as public builders for the nix community.

`x86_64-linux`

```
build-box.nix-community.org ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIElIQ54qAy7Dh63rBudYKdbzJHrrbrrMXLYl7Pkmk88H
```

`aarch64-linux`

```
aarch64-build-box.nix-community.org ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG9uyfhyli+BRtk64y+niqtb+sKquRGGZ87f4YRc8EE1
```

`aarch64-darwin`, `x86_64-darwin`

```
darwin-build-box.nix-community.org ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKMHhlcn7fUpUuiOFeIhDqBzBNFsbNqq+NpzuGX3e6zv
```

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

### Configuring a NixOS system for remote builds

Warning: **_DO NOT_** use this builder to build your NixOS configuration or any derivation of this sort. This is a huge security risk that can compromise your system.

The following reference configuration can be used to configure the nix cli to use the remote builder when building "aarch64-darwin", "x86_64-darwin" packages:

```nix
{
  programs.ssh.knownHosts."darwin-build-box.nix-community.org".publicKey =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFz8FXSVEdf8FvDMfboxhB5VjSe7y2WgSa09q1L4t099";

  nix = {
    distributedBuilds = true;
    buildMachines = [
      {
        hostName = "darwin-build-box.nix-community.org";
        maxJobs = 32;
        sshKey = "/root/a-private-key";
        sshUser = "your-user-name";
        systems = [ "aarch64-darwin" "x86_64-darwin" ];
        supportedFeatures = [ "big-parallel" "benchmark" ];
      }
    ];
  };
}
```

Or for `x86_64-linux` builder:

```nix
{
  programs.ssh.knownHosts."build-box.nix-community.org".publicKey =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIElIQ54qAy7Dh63rBudYKdbzJHrrbrrMXLYl7Pkmk88H";

  nix = {
    distributedBuilds = true;
    buildMachines = [
      {
        hostName = "build-box.nix-community.org";
        maxJobs = 64;
        sshKey = "/root/a-private-key";
        sshUser = "your-user-name";
        system = "x86_64-linux";
        supportedFeatures = [ "big-parallel" "benchmark" "nixos-test" ];
      }
    ];
  };
}

**Note:** Make sure the SSH key specified above does *not* have a
password, otherwise `nix-build` will give an error along the lines of:

> unable to open SSH connection to
> 'ssh://your-user-name@darwin-build-box.nix-community.org': cannot connect to
> 'your-user-name@darwin-build-box.nix-community.org'; trying other available
> machines...

Then run an initial SSH connection as root to setup the trust
fingerprint:

```
$ sudo -i
# ssh your-user-name@darwin-build-box.nix-community.org -i /root/a-private-key
```

Or for `x86_64-linux` builder:

```
$ sudo -i
# ssh your-user-name@build-box.nix-community.org -i /root/a-private-key
```

Now commands like `nix-build . -A hello --argstr system aarch64-darwin` should work.
