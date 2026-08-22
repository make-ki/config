# modules/desktop.nix
# Hyprland compositor, SDDM display manager, Wayland, PipeWire audio
{ config, pkgs, ... }:

{
  # Hyprland (Wayland compositor)
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    # Launch Hyprland via UWSM (Universal Wayland Session Manager).
    # This is required for SDDM's Wayland sessions to work on this nixpkgs:
    # SDDM starts Wayland sessions through the `wayland-session-bindpid@.service`
    # user unit, which is only provided by `programs.uwsm`. Without it the
    # session fails to start and the screen stays blank after login.
    withUWSM = true;
  };

  programs.hyprlock.enable = true;
  security.pam.services.hyprlock = { };

  # SDDM display manager (Wayland session support)
  services.displayManager = {
    # UWSM manages the Wayland session lifecycle; the desktop file is
    # `hyprland-uwsm.desktop` when `programs.hyprland.withUWSM = true`.
    # Using "hyprland" here would launch the non-UWSM entry, which lacks
    # the `wayland-session-bindpid@.service` systemd unit that SDDM's
    # Wayland mode needs — causing a blank screen after login.
    defaultSession = "hyprland-uwsm";
    sddm = {
      enable = true;
      wayland.enable = true;
    };
  };

  # Hyprlock before suspend
  systemd.user.services.hyprlock-suspend = {
    description = "Hyprlock before suspend";
    wantedBy = [ "suspend.target" ];
    before = [ "suspend.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.hyprlock}/bin/hyprlock";
    };
  };

  # Wayland environment variables
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # XDG portals (file picker, screen sharing, etc.)
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
  };

  # Audio — PipeWire (replaces PulseAudio)
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;

    # Custom USB audio config for KTMicro mic
    # Note: wireplumber >= 0.5 uses the nested `actions = { update-props = ... }`
    # form; the old `actions.update-props = ...` syntax is rejected at parse time.
    wireplumber.configPackages = [
      (pkgs.writeTextDir "share/wireplumber/wireplumber.conf.d/99-usb-default.conf" ''
        monitor.alsa.rules = [
          {
            matches = [
              {
                device.name = "~alsa_card.usb-KTMicro_CDS.KT_USB_Audio_.*"
              }
            ]
            actions = {
              update-props = {
                device.profile-set = "output:analog-stereo+input:mono-fallback"
                node.default-sink = true
                node.pause-on-idle = false
                priority.driver = 2000
              }
            }
          }
        ]
      '')
    ];
  };

  # Redshift (blue light filter)
  location.provider = "manual";
  location.latitude = 0.0;
  location.longitude = 0.0;
  services.redshift = {
    enable = true;
    temperature = {
      day = 5000;
      night = 5000;
    };
  };
}
