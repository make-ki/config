# home/stark/hyprland.nix
# Desktop configs: Hyprland compositor, hypridle, awww, Waybar, Kitty, Wofi.
#
# The actual config files live in ./dotfiles/ and get symlinked into ~/.config.
# Symlinked files point into the read-only nix store, so edit them HERE and
# run `rebuild` — don't edit the files in ~/.config directly.
{ ... }:

{
  home.file = {
    # Hyprland + hypridle + awww + helper scripts (wofi_search.sh, waybar_hover.sh)
    ".config/hypr" = {
      source = ./dotfiles/hypr;
      recursive = true;
    };

    # Waybar status bar
    ".config/waybar" = {
      source = ./dotfiles/waybar;
      recursive = true;
    };

    # Kitty terminal
    ".config/kitty" = {
      source = ./dotfiles/kitty;
      recursive = true;
    };

    # Wofi app launcher
    ".config/wofi" = {
      source = ./dotfiles/wofi;
      recursive = true;
    };
  };
}
