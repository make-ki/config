# home/stark/shell.nix
# Shell-level user files:
#   - ~/.profile       (aliases: kali VM, VPNs, cd shortcuts, god(), ...)
#                      (sourced by ~/.zshrc and ~/.bashrc)
#   - ~/.local/bin/    (dual-audio, env, env.fish — sourced by the shells)
#
# Files are managed individually so the rest of ~/.local/bin (e.g. the `agy`
# binary) stays untouched. Note: ~/.zshrc itself is NOT managed here — it's
# configured through NixOS (modules/shell.nix) and contains a plaintext API
# key that should not be committed to this repo.
{ ... }:

{
  home.file = {
    ".profile".source = ./dotfiles/profile;

    ".local/bin/dual-audio".source = ./dotfiles/local-bin/dual-audio;
    ".local/bin/env".source = ./dotfiles/local-bin/env;
    ".local/bin/env.fish".source = ./dotfiles/local-bin/env.fish;
  };
}
