{
  config,
  inputs,
  lib,
  ...
}:
let
  freebsdVM = inputs.self.nixbsdConfigurations."${config.networking.hostName}-freebsd";
in
{
  # telegraf metrics from vm
  networking.firewall.allowedTCPPorts = [ 39273 ];

  environment.etc."nix/freebsd-builder-key" = {
    mode = "0600";
    # https://github.com/NixOS/nixpkgs/blob/1a4711b6be669d31f21b417a7f8b60801367dfee/nixos/modules/profiles/keys/ssh_host_ed25519_key
    text = ''
      -----BEGIN OPENSSH PRIVATE KEY-----
      b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAAAMwAAAAtzc2gtZW
      QyNTUxOQAAACCQVnMW/wZWqrdWrjrRPhfEFFq1KLYguagSflLhFnVQmwAAAJASuMMnErjD
      JwAAAAtzc2gtZWQyNTUxOQAAACCQVnMW/wZWqrdWrjrRPhfEFFq1KLYguagSflLhFnVQmw
      AAAEDIN2VWFyggtoSPXcAFy8dtG1uAig8sCuyE21eMDt2GgJBWcxb/Blaqt1auOtE+F8QU
      WrUotiC5qBJ+UuEWdVCbAAAACnJvb3RAbml4b3MBAgM=
      -----END OPENSSH PRIVATE KEY-----
    '';
  }
  // lib.optionalAttrs config.services.hydra.enable {
    user = "hydra-queue-runner";
  };

  nix.distributedBuilds = true;
  nix.buildMachines = [
    {
      hostName = "freebsd-builder";
      maxJobs = 1; # https://github.com/nix-community/infra/issues/1928
      protocol = "ssh";
      sshKey = "/etc/nix/freebsd-builder-key";
      sshUser = "nix";
      supportedFeatures = [ "big-parallel" ];
      systems = [ "x86_64-freebsd" ];
    }
  ];

  programs.ssh.extraConfig = ''
    Host freebsd-builder
      Hostname 127.0.0.1
      HostKeyAlias freebsd-builder
      Port 31022
  '';

  programs.ssh.knownHosts.freebsd-builder = {
    hostNames = [ "freebsd-builder" ];
    publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJBWcxb/Blaqt1auOtE+F8QUWrUotiC5qBJ+UuEWdVCb root@nixos";
  };

  systemd.services.vm-builder = {
    wantedBy = [
      config.systemd.targets.multi-user.name
    ];
    path = [
      freebsdVM.config.system.build.vm
    ];
    script = ''
      rm -f *.qcow2
      run-nixbsd-freebsd-vm
    '';
    serviceConfig = {
      User = "vm-builder";
      Group = "vm-builder";
      Restart = "on-failure";
      WorkingDirectory = "/var/lib/vm-builder";
    };
  };

  users.users.vm-builder = {
    createHome = true;
    home = "/var/lib/vm-builder";
    isNormalUser = true;
    group = "vm-builder";
  };
  users.groups.vm-builder = { };
}
