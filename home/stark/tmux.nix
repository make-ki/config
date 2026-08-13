# home/stark/tmux.nix
# Tmux configuration.
#
# The config itself (moved from ~/.tmux.conf) is embedded from
# ./dotfiles/tmux.conf. TPM plugins are NOT managed here — tpm clones them
# into ~/.tmux/plugins on first use (open tmux, press prefix + I).
{ ... }:

{
  programs.tmux = {
    enable = true;
    # Note: this file uses `run '~/.tmux/plugins/tpm/tpm'` — tpm must be
    # installed once (prefix + I) after a fresh setup.
    extraConfig = builtins.readFile ./dotfiles/tmux.conf;
  };
}
