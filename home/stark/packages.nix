# home/stark/packages.nix
# User-level packages — things only needed in your interactive session.
# (Most packages are system-wide in modules/system.nix instead.)
#
# With home-manager.useUserPackages = true these get merged into the
# system profile, so they're available everywhere like system packages.
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    bat      # the `cat` alias in modules/shell.nix uses `bat --paging=never`
    ripgrep  # used by kickstart.nvim (:Telescope live_grep)
    fd       # used by kickstart.nvim (:Telescope find_files)
    lazygit  # used by kickstart.nvim's lazygit integration (no config yet)
    # tmux is pulled in automatically by programs.tmux.enable (see tmux.nix)
  ];
}
