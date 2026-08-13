# home/stark/git.nix
# Git identity + defaults (moved from ~/.gitconfig).
#
# home-manager writes this to ~/.config/git/config. The old ~/.gitconfig
# is no longer needed once you've rebuilt — remove it with:
#   rm ~/.gitconfig
{ ... }:

{
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "makeki";
        email = "motivationalboosto@gmail.com";
      };
      init.defaultBranch = "main";
      pull.rebase = false;
      # Use SSH for github.com instead of HTTPS
      url."git@github.com:".insteadOf = "https://github.com/";
    };
  };
}
