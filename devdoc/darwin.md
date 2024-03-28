### Darwin setup

NOTE: this guide is for Hetzner Mac Mini M1.

#### Setup temporary ssh keys

```sh
ssh-copy-id $USER@$IP
```

#### Setup passwordless sudo for admin group

```sh
echo "%admin ALL = (ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/admin-nopasswd
```

### Enable ssh access for all users

```sh
sudo dscl . change /Groups/com.apple.access_ssh RecordName com.apple.access_ssh com.apple.access_ssh-disabled
```

#### Check and install updates for current macOS version

Updating beyond the currently installed macOS version may not be advisable.

```console
> sw_vers -productVersion
12.1
```

```console
> softwareupdate --list
Software Update Tool

Finding available software
Software Update found the following new or updated software:
* Label: Command Line Tools for Xcode-13.2
        Title: Command Line Tools for Xcode, Version: 13.2, Size: 577329KiB, Recommended: YES,
* Label: Command Line Tools for Xcode-13.4
        Title: Command Line Tools for Xcode, Version: 13.4, Size: 705462KiB, Recommended: YES,
* Label: Command Line Tools for Xcode-14.2
        Title: Command Line Tools for Xcode, Version: 14.2, Size: 687573KiB, Recommended: YES,
* Label: macOS Monterey 12.6.7-21G651
        Title: macOS Monterey 12.6.7, Version: 12.6.7, Size: 11395817K, Recommended: YES, Action: restart,
* Label: macOS Ventura 13.4.1-22F82
        Title: macOS Ventura 13.4.1, Version: 13.4.1, Size: 11494827K, Recommended: YES, Action: restart,
```

```console
> sudo softwareupdate --install --restart 'macOS Monterey 12.6.7-21G651'
```

`--restart` will reboot the machine automatically.

### Check and install rosetta for x86_64 support

`sudo` isn't needed for this `softwareupdate`.

```sh
pgrep oahd || softwareupdate –-install-rosetta –-agree-to-license
```

### Install nix

https://github.com/DeterminateSystems/nix-installer#usage

```sh
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --no-modify-profile
```

`/nix/receipt.json` has a record of all the changes done by the nix installer.

```sh
. '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
```

### Install nix-darwin

```sh
nix --extra-experimental-features 'flakes nix-command' --option accept-flake-config true \
  run 'github:LnL7/nix-darwin#darwin-rebuild' -- switch --flake '.#$HOSTNAME'
```

Remove packages installed to the default profile.

```sh
sudo nix-env -q
```

```sh
sudo nix-env -e nix nss-cacert
```

Doctor should show no warnings.

```sh
nix doctor
```

Reboot.

```sh
shutdown -r now
```

### May be needed with other hardware providers

Delete Xcode command line tools and app.

```sh
sudo rm -rf /Library/Developer/CommandLineTools
```

```sh
sudo rm -rf /Applications/Xcode.app
```

Check `/Applications` to make sure there aren't other `Xcode.app` versions.

Reset the developer directory path.

```sh
sudo xcode-select --reset
```
