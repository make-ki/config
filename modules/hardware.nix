# modules/hardware.nix
# NVIDIA GPU drivers, graphics acceleration, Steam hardware
{ config, pkgs, ... }:

{
  # NVIDIA driver
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware = {
    nvidia = {
      modesetting.enable = true;
      powerManagement = {
        enable = true;
        finegrained = false;
      };
      open = true;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;

      # Hybrid laptop (Intel Alder Lake iGPU + RTX 3050): the internal panel
      # (eDP-1) is wired to the Intel GPU; the NVIDIA GPU has no connected
      # outputs. Use PRIME render offload so the desktop always runs on the
      # Intel GPU and the NVIDIA GPU is available on demand via
      # `nvidia-offload <command>` (e.g. for Steam games / CUDA).
      prime = {
        offload = {
          enable = true;
          enableOffloadCmd = true;
        };
        intelBusId = "PCI:0:2:0";   # lspci: 00:02.0 Intel UHD Graphics
        nvidiaBusId = "PCI:1:0:0";  # lspci: 01:00.0 GeForce RTX 3050
      };
    };

    # OpenGL / Vulkan / 32-bit support (needed for Steam, Wine, etc.)
    graphics = {
      enable = true;
      enable32Bit = true;
    };
  };

  # Steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

}
