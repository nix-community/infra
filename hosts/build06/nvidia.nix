{
  hardware.graphics = {
    enable = true;
  };

  hardware.nvidia = {
    open = true;
  };

  programs.nix-required-mounts = {
    enable = true;
    presets.nvidia-gpu.enable = true;
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  #services.telegraf.extraConfig.inputs.nvidia_smi.bin_path = "/run/current-system/sw/bin/nvidia-smi";
}
