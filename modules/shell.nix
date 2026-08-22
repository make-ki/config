# modules/shell.nix
# ZSH shell configuration, oh-my-zsh, aliases, prompt
{ config, pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    syntaxHighlighting.enable = true;
    autosuggestions.enable = true;

    interactiveShellInit = ''
      source ${pkgs.fzf}/share/fzf/key-bindings.zsh
      source ${pkgs.fzf}/share/fzf/completion.zsh
    '';

    ohMyZsh = {
      enable = true;
      plugins = [ "git" ];
      theme = "robbyrussell";
    };

    # Prompt: user@host ~/path ❯
    promptInit = ''
      PROMPT='%F{cyan}%n%f@%F{blue}%m%f %F{magenta}%~%f ❯ '
    '';

    # Useful aliases
    shellAliases = {
      # NixOS management
      rebuild = "sudo nixos-rebuild switch --flake ~/nixos-config";
      # Update = refresh flake.lock (nixpkgs is pinned and won't move — see
      # flake.nix; this updates home-manager), BUILD first, and only switch if
      # the build succeeds — a broken update never nukes the running system.
      update = "cd ~/nixos-config && nix flake update && nixos-rebuild build --flake . && sudo nixos-rebuild switch --flake .";
      # If an update breaks something: switch back to the previous generation.
      rollback = "sudo nixos-rebuild switch --flake ~/nixos-config --rollback";
      nixos-list = "nix profile history --profile /nix/var/nix/profiles/system";
      nixos-clean = "sudo nix-collect-garbage -d";

      # Quick aliases
      ll = "ls -la";
      gs = "git status";
      gp = "git push";
      cat = "bat --paging=never";

      # PRIME render offload — run GPU-heavy apps on the NVIDIA GPU.
      # Usage: gpu steam, gpu steam-run ./game, gpu blender, etc.
      gpu = "env __NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia";
    };
  };

  # Set ZSH as the default shell
  users.users.stark.shell = pkgs.zsh;
}
