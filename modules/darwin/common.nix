{ inputs, config, lib, ... }:
{
  imports = [
    inputs.home-manager.darwinModules.home-manager
    ./shared.nix
    ./shared-nix-settings.nix
  ];

  nix.settings.trusted-users = [
    "@admin"
    config.deployUser
  ];

  nix.useDaemon = lib.mkDefault true;

  nix.configureBuildUsers = lib.mkDefault true;

  services.dnsmasq.enable = lib.mkDefault true;

  # Create /etc/bashrc that loads the nix-darwin environment.
  programs.zsh.enable = lib.mkDefault true;

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = lib.mkDefault true;

  programs.zsh.loginShellInit = ''
    echo This machine has nix-darwin based declarative configuration at https://github.com/holochain/holochain-infra.
  '';

  # home-manager settings
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users."${config.deployUser}" = {
    home.stateVersion = "22.11";

    # https://github.com/malob/nixpkgs/blob/master/home/default.nix

    # Direnv, load and unload environment variables depending on the current directory.
    # https://direnv.net
    # https://rycee.gitlab.io/home-manager/options.html#opt-programs.direnv.enable
    programs.direnv.enable = true;
    programs.direnv.nix-direnv.enable = true;

    # Htop
    # https://rycee.gitlab.io/home-manager/options.html#opt-programs.htop.enable
    programs.htop.enable = true;
    programs.htop.settings.show_program_path = true;
  };

  system.activationScripts.postActivation.text =
    let
      authorizedKeysDeployUser = "/etc/ssh/authorized_keys.d/${config.deployUser}";
      sshdAuthorizedKeysConf = "/etc/ssh/sshd_config.d/200-authorized-keys.conf";
    in
    ''
      mkdir -p $(dirname ${sshdAuthorizedKeysConf})
      echo "AuthorizedKeysFile .ssh/authorized_keys /etc/ssh/authorized_keys.d/%u" > ${sshdAuthorizedKeysConf}
      chmod 444 ${sshdAuthorizedKeysConf}

      mkdir -p $(dirname ${authorizedKeysDeployUser})
      echo > ${authorizedKeysDeployUser}
      chmod 444 ${authorizedKeysDeployUser}
      ${builtins.concatStringsSep "\n" (
        lib.attrsets.mapAttrsToList (
          keyName: keyFile: ''
            echo '# ${keyName}' >> ${authorizedKeysDeployUser}
            cat ${keyFile} >> ${authorizedKeysDeployUser}
          ''
        ) (
          lib.filterAttrs (name: _: lib.hasPrefix "keys_" name) (
            inputs
            # this key was used for testing and only serves demonstration purposes
            // {
              keys_testing =
                builtins.toFile "key" "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDy46BfrpQQsc8i+5CK31zmR2laaDDmFDDQBYsRxHsyq79jr6X4zShnyU7l/LUJbg12ZYrA64EwFZ9eqjuHJ4GY3C6IFoyyQQ5UXECbSMhASiw2cEgzj0r5sAXNXUxblLBLmaQoWCU6i8RWGUPfMgg3oKI720aZmXRNz3nJDTs+mXWLEXLsCrDmmxg+YEqhRZeE0Eg3QQ4bZ5v3bdrSHC6bBC6kTP6ik4qYNfXNwiwB5WT+8XnCQHMXS8gtJ7xF/heHTKhfCMmEzW4B0dx6788VlANGcRv4Sj0W/ah76YBHBaOWpR61eDixrir/lXo9Ojl9mpr+julsxmsS28OfJT5m1PaOWyPaQPQflchm7vzt8Y36KWZCBtEN7lnPOLk7vjYl8vvUFb4gVA5TpT65P0BwjGcp4Yy3retwcrtPbSTy0uA/qom6J9ZF44MtQ+1M6T38M1oEbAgqPb/Kz3X461CfmQ3x4P93vUcvyH4mkn4/GnqC7dnw2BcH1Ig+BC9eh5s=";
            }
          )
        )
      )}
      launchctl kickstart -k system/com.openssh.sshd
    '';
}
