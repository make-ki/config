# home/stark/opencode.nix
# OpenCode AI agent config:
#   - opencode.jsonc   (default agent, MCP servers)
#   - agents/          (orchestrator + code-reviewer/researcher/debugger/architect)
#   - skills/          (grill-me, stop-slop, handoff, exam-prep)
#   - plugins/         (safety-net.js — blocks .env reads + destructive bash)
#
# The actual files live in ./dotfiles/opencode/ and get symlinked into
# ~/.config/opencode. Symlinked files point into the read-only nix store, so
# edit them HERE and run `rebuild` — don't edit the files in ~/.config directly.
#
# NOTE: the machine-local bits of ~/.config/opencode (node_modules, package.json,
# bun.lock, package-lock.json, .gitignore) are intentionally NOT managed — opencode
# installs plugin deps there at runtime.
{ ... }:

{
  home.file = {
    ".config/opencode/opencode.jsonc".source = ./dotfiles/opencode/opencode.jsonc;

    ".config/opencode/agents" = {
      source = ./dotfiles/opencode/agents;
      recursive = true;
    };

    ".config/opencode/skills" = {
      source = ./dotfiles/opencode/skills;
      recursive = true;
    };

    ".config/opencode/plugins" = {
      source = ./dotfiles/opencode/plugins;
      recursive = true;
    };
  };
}
