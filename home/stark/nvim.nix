# home/stark/nvim.nix
# Neovim config (a kickstart.nvim fork, see ./dotfiles/nvim/README.md).
#
# init.lua, lua/, doc/ and .stylua.toml are symlinked from ./dotfiles/nvim
# into ~/.config/nvim. Edit them here and run `rebuild`.
#
# Two things are intentionally NOT managed, so the plugin managers can keep
# writing to them:
#   - pack/            -> copilot.vim (native pack, git-managed)
#   - lazy-lock.json   -> written by lazy.nvim when you update plugins
{ ... }:

{
  home.file = {
    ".config/nvim/init.lua".source = ./dotfiles/nvim/init.lua;
    ".config/nvim/lua" = {
      source = ./dotfiles/nvim/lua;
      recursive = true;
    };
    ".config/nvim/doc" = {
      source = ./dotfiles/nvim/doc;
      recursive = true;
    };
    ".config/nvim/.stylua.toml".source = ./dotfiles/nvim/.stylua.toml;
  };
}
