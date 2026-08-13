# Home Manager — What the Heck Is It?

You have NixOS managing your **system**: packages, services, users, the kernel,
bootloader. But the stuff *you* configure as a user — `~/.config/hypr/hyprland.conf`,
`~/.tmux.conf`, `~/.config/nvim/` — was living in plain files in your home
directory, outside any kind of version control or reproducibility.

**Home Manager** is the answer: it manages your *user-level* config the same way
NixOS manages your *system-level* config. Your dotfiles become declarative Nix
modules, get symlinked into place from the nix store, and are rebuilt atomically
with `nixos-rebuild switch`.

```
┌─────────────────────────────┐     ┌──────────────────────────────┐
│  NixOS (system)             │     │  Home Manager (user)         │
│  /etc, kernel, services,    │     │  ~/.config/hypr, ~/.tmux.conf │
│  system-wide packages       │     │  ~/.config/nvim, ~/.gitconfig │
│  -> modules/*.nix           │     │  -> home/stark/*.nix          │
└─────────────────────────────┘     └──────────────────────────────┘
          both built by:  nixos-rebuild switch --flake ~/nixos-config
```

---

## 1. How it's wired into this repo

Three places make it work:

| File | What it does |
|------|--------------|
| `flake.nix` | Declares `home-manager` as a flake input (`inputs.nixpkgs.follows = "nixpkgs"` so it shares your nixpkgs instead of building a second copy) and adds `home-manager.nixosModules.home-manager` to the system modules |
| `hosts/nixos/default.nix` | Configures the module: `users.stark = import ../../home/stark;` plus a few options (see below) |
| `home/stark/default.nix` | The **entry point** of your user config. Imports per-topic modules (tmux, nvim, hyprland, git, packages) |

The options in `hosts/nixos/default.nix`:

- `useGlobalPkgs = true` — home-manager reuses the system's `pkgs` (no duplicate package builds).
- `useUserPackages = true` — your `home.packages` get merged into the system profile, so programs are available everywhere (not just in your shell).
- `backupFileExtension = "backup"` — on the *first* activation, any existing dotfile that home-manager now manages is renamed to `name.backup` instead of erroring out.

---

## 2. What's managed, and where the real files live

The actual file **contents** live in `home/stark/dotfiles/`. home-manager
symlinks them into your home directory (that's why the config files on disk
show up as links into `/nix/store/...`).

| Program | Config files | Managed by |
|---------|--------------|------------|
| Hyprland / hypridle / hyprpaper | `home/stark/dotfiles/hypr/` → `~/.config/hypr/` | `home/stark/hyprland.nix` |
| Waybar | `home/stark/dotfiles/waybar/` → `~/.config/waybar/` | `home/stark/hyprland.nix` |
| Kitty | `home/stark/dotfiles/kitty/` → `~/.config/kitty/` | `home/stark/hyprland.nix` |
| Wofi | `home/stark/dotfiles/wofi/` → `~/.config/wofi/` | `home/stark/hyprland.nix` |
| Mako (notifications) | `home/stark/dotfiles/mako/` → `~/.config/mako/` (had no config before — was running with defaults) | `home/stark/apps.nix` |
| Btop | `home/stark/dotfiles/btop/` → `~/.config/btop/` | `home/stark/apps.nix` |
| Neofetch | `home/stark/dotfiles/neofetch/` → `~/.config/neofetch/` | `home/stark/apps.nix` |
| Tmux | `home/stark/dotfiles/tmux.conf` (from your old `~/.tmux.conf`) | `home/stark/tmux.nix` (`programs.tmux`) |
| Neovim | `home/stark/dotfiles/nvim/` (init.lua, lua/, doc/) → `~/.config/nvim/` | `home/stark/nvim.nix` |
| Git | identity + defaults (was `~/.gitconfig`) → `~/.config/git/config` | `home/stark/git.nix` (`programs.git`) |
| Shell aliases | `home/stark/dotfiles/profile` (was `~/.profile`: kali VM, VPNs, cd shortcuts, god()) | `home/stark/shell.nix` |
| Shell scripts | `home/stark/dotfiles/local-bin/` (dual-audio, env) → `~/.local/bin/` | `home/stark/shell.nix` |
| User packages | `bat`, `ripgrep`, `fd`, `lazygit`, `tmux` | `home/stark/packages.nix` |

---

## 3. How to make a change

1. Edit the file in `home/stark/dotfiles/...` (or the `.nix` module).
2. Run your normal rebuild:

   ```bash
   rebuild   # = sudo nixos-rebuild switch --flake ~/nixos-config
   ```

   Because home-manager is integrated via the NixOS module, one command updates
   **both** system and user configs — no separate `home-manager switch` needed.

3. For configs read at runtime (tmux, nvim, waybar...) the app picks up the
   new file on its next start. Hyprland re-reads on `hyprctl reload` (or just
   log out/in).

> ⚠️ **The symlink gotcha:** files symlinked from the nix store are
> **read-only**. You can't edit `~/.config/hypr/hyprland.conf` directly anymore
> — and even if you could, the change would vanish on the next rebuild.
> Always edit in `home/stark/dotfiles/`, then rebuild. That's the point: the
> repo is the single source of truth.

---

## 4. Things to know about specific programs

### Tmux + TPM
`programs.tmux` installs the tmux binary and writes the config to
`~/.config/tmux/tmux.conf`. Your old `~/.tmux.conf` is no longer used after the
first rebuild — remove it:

```bash
rm ~/.tmux.conf ~/.gitconfig   # superseded by home-manager
```

TPM **plugins** (`~/.tmux/plugins/`) are *not* managed by home-manager — tpm
clones them itself. After a fresh setup, open tmux and press `prefix + I`
(Ctrl-b then capital I) to install plugins.

### Neovim + lazy.nvim
`init.lua`, `lua/` and `doc/` are managed. Two things are deliberately left
unmanaged so plugin managers can keep writing to them:

- `~/.config/nvim/pack/` — copilot.vim (vim's native pack system)
- `~/.config/nvim/lazy-lock.json` — written by lazy.nvim on `:Lazy sync`

Plugins themselves install into `~/.local/share/nvim/` (writable), so only
config files are read-only.

### Git
Your old `~/.gitconfig` (name, email, ssh-insteadOf) moved to
`home/stark/git.nix`. After the first rebuild git reads
`~/.config/git/config`; the old `~/.gitconfig` would override it, so remove it
(see above).

### Hyprland
The hyprland config in `home/stark/dotfiles/hypr/hyprland.conf` already has the
fixes for the errors you were seeing:

- `togglesplit` is now `layoutmsg, togglesplit` (the old dispatcher was removed).
- `dwindle:pseudotile` was removed (it no longer exists in v0.45+).
- The `monitor=HDMI-A-5, ..., mirror, eDP-1` line was removed — that port is on
  the NVIDIA GPU, which has no CRTC under PRIME render offload.
- `exec-once = hypridle` was removed — the hypridle package already ships a
  systemd user service, so it was running twice.
- Stale `WLR_*` env vars were dropped; `AQ_DRM_DEVICES` now only hands the
  compositor the Intel GPU (`/dev/dri/card1`), which kills the
  `getCurrentCRTC: No CRTC` noise on the next full login.

---

## 5. Adding something new to home-manager

Say you want to manage `~/.config/btop/btop.conf`:

1. Copy the file in: `cp ~/.config/btop/btop.conf home/stark/dotfiles/btop/`
2. Add it in `home/stark/hyprland.nix` (or a new module) under `home.file`:

   ```nix
   home.file.".config/btop" = {
     source = ./dotfiles/btop;
     recursive = true;
   };
   ```

3. `rebuild`.

Prefer a declarative option when one exists (e.g. `programs.git`, 
`programs.tmux`) — they're smarter than raw file symlinks. For anything else,
`home.file` / `xdg.configFile` symlinks work fine.

---

## 6. Handy commands

| Command | What it does |
|---------|--------------|
| `rebuild` | Rebuild + switch system AND home-manager (the only command you need) |
| `home-manager news` | Show home-manager release notes |
| `home-manager generations` | List past user config generations |
| `nixos-list` / `nixos-clean` | System generations / garbage collect (from `modules/shell.nix`) |
| `nix flake update home-manager` | Update just the home-manager input |

---

## 7. The mental model in one paragraph

NixOS gives you a reproducible **machine**; home-manager gives you a
reproducible **desktop**. Your dotfiles stop being a pile of unversioned files
in `~` and become part of the same flake that builds your system — same
workflow, same atomic switches, same rollback (old generations keep your old
dotfiles too). When you set up a new machine, `rebuild` recreates both the
system and your entire home directory from this one repo.

Want to undo a change? Rebuild the previous generation:
`sudo nixos-rebuild switch --flake ~/nixos-config --rollback` — it reverts
system *and* home-manager together.
