# Nix Language Basics — What You'll See Everywhere

## 1. Attribute Sets (the core data structure)

An attribute set is like a JSON object or Python dict. It's THE thing you work with in Nix.

```nix
{
  name = "firefox";
  version = "128.0";
  enable = true;
}
```

Access fields with `.`:
```nix
config.services.openssh.enable   # → true
pkgs.firefox.name                # → "firefox"
```

### Nested attribute sets:
```nix
{
  boot = {
    loader = {
      systemd-boot.enable = true;
    };
  };
}
# This is the same as: boot.loader.systemd-boot.enable = true
```

---

## 2. Functions

Every Nix file is a function. The `{ config, pkgs, ... }:` at the top is the function signature — it receives the NixOS module system's arguments.

```nix
# A module is a function that takes args and returns an attribute set
{ config, pkgs, lib, ... }:
{
  # ... return an attr set with config options
}
```

### Common arguments you'll use:
| Argument | What it gives you |
|----------|------------------|
| `config` | The FINAL evaluated config (read-only, for referencing other options) |
| `pkgs`   | The nixpkgs package set (all available packages) |
| `lib`    | Utility functions (`mkIf`, `mkMerge`, `mkOption`, string ops, etc.) |
| `options`| All declared options (rarely used directly) |

### Simple function:
```nix
let
  add = x: y: x + y;
in
add 2 3   # → 5
```

---

## 3. `let ... in` (local variables)

`let` binds names for use in an expression. Think of it as `const` in JS.

```nix
let
  myName = "stark";
  greeting = "Hello, ${myName}!";
in
greeting   # → "Hello, stark!"
```

In a module:
```nix
{ config, pkgs, ... }:
let
  myBrowser = pkgs.firefox.override {
    nativeBuildInputs = [ pkgs.wrapGAppsHook ];
  };
in
{
  environment.systemPackages = [ myBrowser ];
}
```

---

## 4. `with` (bring attributes into scope)

`with` makes all attributes of an attr set available without prefixing.

```nix
# Without with:
environment.systemPackages = [ pkgs.firefox pkgs.obsidian pkgs.git ];

# With with — same thing, less typing:
environment.systemPackages = with pkgs; [ firefox obsidian git ];
```

You see `with pkgs;` EVERYWHERE in NixOS configs.

### `with` with nested sets:
```nix
programs.zsh = {
  oh-my-zsh = {
    enable = true;
    plugins = with pkgs; [ git docker ];
  };
};
```

---

## 5. String Interpolation (`${}`)

Embed expressions inside strings with `${}`:

```nix
let
  name = "stark";
  version = "1.0";
in
"${name}-${version}"   # → "stark-1.0"
```

In a shell script block:
```nix
ExecStart = "${pkgs.cloudflared}/bin/cloudflared tunnel run";
# The ${pkgs.cloudflared} evaluates to the /nix/store/... path
```

---

## 6. Multi-line Strings (`'' ... ''`)

Two single quotes for multi-line strings. Indentation is auto-stripped.

```nix
let
  script = ''
    echo "Hello, world!"
    echo "Current user: $USER"
  '';
in
script   # → "echo \"Hello, world!\"\necho \"Current user: $USER\"\n"
```

Use `${}` inside multi-line strings too:
```nix
ExecStart = ''
  ${pkgs.bash}/bin/bash -c "echo Running from ${pkgs.hello}/bin/hello"
'';
```

---

## 7. Lists

Lists are space-separated, no commas:

```nix
[ "one" "two" "three" ]
[ pkgs.git pkgs.vim pkgs.curl ]
```

Combine lists with `++`:
```nix
let
  base = [ pkgs.git pkgs.vim ];
  extra = [ pkgs.curl ];
in
base ++ extra   # → [ pkgs.git pkgs.vim pkgs.curl ]
```

---

## 8. Conditionals (`mkIf`, `mkMerge`)

These are NixOS module system functions for conditional config:

```nix
{ config, pkgs, lib, ... }:
{
  # Only enable docker if hostname is "devhost"
  virtualisation.docker.enable = lib.mkIf (config.networking.hostName == "devhost") true;

  # Merge multiple lists conditionally
  environment.systemPackages = lib.mkMerge [
    [ pkgs.git ]                                              # always
    (lib.mkIf config.services.xserver.enable [ pkgs.firefox ]) # only with X11
  ];
}
```

---

## 9. `import` (loading other files)

`import` evaluates a Nix file and returns its value:

```nix
# In flake.nix or a module:
modules = [
  ./hosts/nixos/default.nix   # import is implicit here (Nix auto-imports paths)
  (import ./some-other-file.nix { inherit pkgs; })
];
```

When you write `./some-file.nix` in a list, Nix auto-imports it. That's why `imports = [ ./hardware-configuration.nix ];` works.

---

## 10. `override` and `overrideAttrs` (customizing packages)

```nix
# Change build options
pkgs.firefox.override {
  nativeBuildInputs = [ pkgs.wrapGAppsHook ];
};

# Change the derivation itself (more low-level)
pkgs.hello.overrideAttrs (old: {
  pname = "my-hello";
  version = "2.0";
  buildInputs = old.buildInputs ++ [ pkgs.libbar ];
});
```

---

## 11. The `#` Flake Reference Syntax

When you use `nix run`, `nix develop`, etc., `#` references outputs in your flake:

```bash
nix run .#nixosConfigurations.nixos.config.system.build.toplevel
#         └── flake output  └── attr path inside that output

nix develop .#rust
#             └── devShells.x86_64-linux.rust
```

---

## 12. Recursion (`rec`)

`rec` lets attribute sets reference themselves:

```nix
rec {
  name = "hello-${version}";
  version = "1.0";
}
# name → "hello-1.0"
```

Without `rec`, `name` can't see `version`.

---

## Quick Reference Cheat Sheet

| Syntax | Meaning |
|--------|---------|
| `{ a = 1; b = 2; }` | Attribute set |
| `x: x + 1` | Lambda (anonymous function) |
| `let x = 1; in x` | Local binding |
| `with pkgs; [ git vim ]` | Bring attrs into scope |
| `"Hello ${name}"` | String interpolation |
| `'' multi-line ''` | Multi-line string |
| `[ a b c ]` | List |
| `a ++ b` | List concat |
| `a.b.c` | Nested attr access |
| `import ./file.nix` | Load a nix file |
| `pkgs.foo.override { ... }` | Customize a package |
| `lib.mkIf cond value` | Conditional value |
| `lib.mkMerge [ a b ]` | Merge multiple values |
| `rec { ... }` | Self-referencing attr set |
| `./path.nix` | Relative path (auto-imported) |

---

## What You'll See in Practice

A typical NixOS module looks like this:

```nix
{ config, pkgs, lib, ... }:          # 1. Function signature

let                                   # 2. Local bindings (optional)
  myVar = "something";
in
{
  # 3. Attribute set of config options
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  environment.systemPackages = with pkgs; [   # 4. with + list
    git
    vim
    (mkIf config.services.xserver.enable firefox)  # 5. Conditional
  ];
}
```

The pattern is always: **function → let (optional) → attr set of options**.
