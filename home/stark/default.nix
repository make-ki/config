# home/stark/default.nix
# Entry point for user "stark"'s home-manager configuration.
#
# This file is loaded from hosts/nixos/default.nix via:
#   home-manager.users.stark = import ../../home/stark;
#
# It imports the per-topic modules below. Each module manages the config
# files for one program (tmux, nvim, hyprland, ...).
{ config, pkgs, ... }:

{
  imports = [
    ./apps.nix
    ./git.nix
    ./hyprland.nix
    ./nvim.nix
    ./packages.nix
    ./shell.nix
    ./tmux.nix
  ];

  home = {
    username = "stark";
    homeDirectory = "/home/stark";
    stateVersion = "25.05"; # must match system.stateVersion
  };

  # Lets home-manager manage itself: gives you `home-manager` CLI + `home-manager news`.
  programs.home-manager.enable = true;
}
