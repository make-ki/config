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
      update = "cd ~/nixos-config && nix flake update && sudo nixos-rebuild switch --flake .";
      nixos-list = "nix profile history --profile /nix/var/nix/profiles/system";
      nixos-clean = "sudo nix-collect-garbage -d";

      # Quick aliases
      ll = "ls -la";
      gs = "git status";
      gp = "git push";
      cat = "bat --paging=never";
    };
  };

  # Set ZSH as the default shell
  users.users.stark.shell = pkgs.zsh;
}
