# home/stark/shell.nix
# Shell-level user files:
#   - ~/.profile       (aliases: kali VM, VPNs, cd shortcuts, god(), ...)
#                      (sourced by ~/.zshrc and ~/.bashrc)
#   - ~/.local/bin/    (dual-audio, env, env.fish, steam — sourced by the shells)
#
# Files are managed individually so the rest of ~/.local/bin (e.g. the `agy`
# binary) stays untouched. Note: ~/.zshrc itself is NOT managed here — it's a
# plain file that sources ~/.profile and ~/.local/bin/env. Audited 2026-08-14:
# it contains no secrets, and neither do the managed files above. If you ever
# add an API key to a dotfile, keep it OUT of this repo.
{ ... }:

{
  home.file = {
    ".profile".source = ./dotfiles/profile;

    ".local/bin/dual-audio".source = ./dotfiles/local-bin/dual-audio;
    ".local/bin/env".source = ./dotfiles/local-bin/env;
    ".local/bin/env.fish".source = ./dotfiles/local-bin/env.fish;

    # Steam wrapper — injects NVIDIA env vars so games always use the dGPU.
    # This overrides /usr/bin/steam because ~/.local/bin is earlier in PATH.
    ".local/bin/steam" = {
      source = ./dotfiles/local-bin/steam;
      executable = true;
    };
  };
}
