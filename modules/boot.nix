# modules/boot.nix
# Bootloader, kernel parameters, and boot-related settings
{ config, pkgs, ... }:

{
  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 10;  # Keep last 10 generations to save disk
      };
      efi.canTouchEfiVariables = true;
    };

    kernelParams = [ "nvidia-drm.modeset=1" ];
  };
}
