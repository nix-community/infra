### Darwin setup

NOTE: this guide is for Oakhost Mac Mini M4.

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

### Ensure that Xcode command line tools and/or application aren't installed

Also ensure there aren't multiple versions of `Xcode.app` in `/Applications`.

```sh
ls -la /Applications/
```

```sh
ls -la /Library/Developer/
```

If they are present, remove them and reset the developer directory path.

```sh
sudo rm -rf /Library/Developer/CommandLineTools
```

```sh
sudo rm -rf /Applications/Xcode.app
```

```sh
sudo xcode-select --reset
```

### Disable Apple Intelligence

Should save about ~5GB of disk space.

System Settings -> Apple Intelligence & Siri -> Toggle `Apple Intelligence` off.

(Also need to check that it hasn't been re-enabled after each macOS update.)

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

### Install nix

https://github.com/NixOS/nix-installer

```sh
curl --proto '=https' --tlsv1.2 -sSf -L https://artifacts.nixos.org/nix-installer | sh -s -- install --no-modify-profile
```

`/nix/receipt.json` has a record of all the changes done by the nix installer.

```sh
. '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
```

### Install nix-darwin

```sh
sudo -H nix --extra-experimental-features 'flakes nix-command' --option accept-flake-config true \
  run 'github:nix-darwin/nix-darwin#darwin-rebuild' -- switch --option accept-flake-config true --flake 'github:nix-community/infra#$HOSTNAME'
```

Remove packages installed to the default profile.

```sh
sudo -H nix-env -q
```

```sh
sudo -H nix-env -e nix nss-cacert
```

Config check should show no warnings.

```sh
nix config check
```

Reboot.

```sh
shutdown -r now
```
