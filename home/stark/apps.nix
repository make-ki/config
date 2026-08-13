# home/stark/apps.nix
# Configs for desktop apps that live in ~/.config:
#   - mako    (notification daemon — had NO config before, was running with defaults)
#   - btop    (system monitor: config + themes)
#   - neofetch
#
# lazygit has no config yet (config.yml is empty), so only the package is
# added in packages.nix — you can add a config.yml here later if you want.
{ ... }:

{
  home.file = {
    ".config/mako" = {
      source = ./dotfiles/mako;
      recursive = true;
    };

    ".config/btop" = {
      source = ./dotfiles/btop;
      recursive = true;
    };

    ".config/neofetch" = {
      source = ./dotfiles/neofetch;
      recursive = true;
    };
  };
}
