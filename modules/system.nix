# modules/system.nix
# Networking, system packages, services, virtualization, users, fonts
# This is the "everything else" module — the catch-all.
{ config, pkgs, ... }:

{
  # ─── Networking ──────────────────────────────────────────────
  networking = {
    hostName = "nixos";
    networkmanager.enable = true;
    firewall.trustedInterfaces = [ "virbr0" ];
    bridges.br0.interfaces = [ "enp7s0" ];
  };
  programs.nm-applet.enable = true;

  # ─── Time & Locale ──────────────────────────────────────────
  time.timeZone = "Asia/Kolkata";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_IN"; LC_IDENTIFICATION = "en_IN"; LC_MEASUREMENT = "en_IN";
    LC_MONETARY = "en_IN"; LC_NAME = "en_IN"; LC_NUMERIC = "en_IN";
    LC_PAPER = "en_IN"; LC_TELEPHONE = "en_IN"; LC_TIME = "en_IN";
  };

  # ─── Users ──────────────────────────────────────────────────
  users.users.stark = {
    isNormalUser = true;
    description = "stark";
    extraGroups = [ "networkmanager" "wheel" "docker" "openvpn" "libvirtd" "kvm" "wireshark" ];
    linger = true;  # Enable user-level systemd services
  };

  # ─── Nix Settings ───────────────────────────────────────────
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;  # Deduplicate /nix/store hardlinks
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
  };

  nixpkgs.config.allowUnfree = true;

  # ─── Environment Variables ──────────────────────────────────
  environment.variables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  # ─── System Packages ────────────────────────────────────────
  environment.systemPackages = with pkgs; [
    # Wayland essentials
    hyprland kitty waybar swww mako wl-clipboard grim slurp brightnessctl
    dbus wofi hyprpaper pulseaudio fzf eww hypridle

    # Desktop apps
    firefox qemu obsidian file vlc kdePackages.ark obs-studio
    vesktop pavucontrol easyeffects vscode
    kdePackages.dolphin qbittorrent gef hexedit
    element-desktop distrobox boxbuddy

    # Terminal tools
    jq btop unzip xxd exiftool

    # Dev tools
    git gnumake gcc libgcc neovim
    clang-tools appimage-run virtualenv

    # Languages
    go gopls gotools go-outline golangci-lint delve
    rustc cargo rustfmt rustscan
    python3 python314Packages.pip python3Packages.pip
    nodejs

    # Audio backend packages
    pipewire wireplumber

    # Networking
    openssh lftp wget cloudflared
    openvpn networkmanager-openvpn networkmanagerapplet

    # Qt Wayland support
    qt5.qtwayland qt6.qtwayland

    # Virtualization helpers
    virt-viewer libvirt

    # Fonts
    bibata-cursors

    # Vibes
    opencode
  ];

  # ─── Fonts ──────────────────────────────────────────────────
  fonts = {
    fontDir.enable = true;
    packages = with pkgs; [
      noto-fonts
    ];
  };

  # ─── Services ───────────────────────────────────────────────
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };
  services.openssh.enable = true;
  services.udisks2.enable = true;

  # MySQL
  services.mysql = {
    enable = true;
    package = pkgs.mysql84;
  };

  # Flatpak
  services.flatpak.enable = true;

  # ─── Virtualization ─────────────────────────────────────────
  virtualisation = {
    libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        runAsRoot = true;
      };
    };
    docker.enable = true;
  };
  programs.virt-manager.enable = true;
  programs.wireshark.enable = true;
}
