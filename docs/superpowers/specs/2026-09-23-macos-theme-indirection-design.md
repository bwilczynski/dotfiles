# macOS theme indirection

Date: 2026-09-23

## Problem

Catppuccin Mocha is hardcoded into nine packages. Four of them embed raw hex
values — `jj/config.toml` carries roughly a hundred lines of them,
`lazygit/config.yml`, `zsh/.fzf.zsh` and `starship/.config/starship.toml`
carry the rest — and five more name the theme inline (`ghostty`'s
`theme = Catppuccin Mocha`, tmux's `@catppuccin_flavor`, `herdr`'s
`name = "catppuccin"`, nvim's plugin spec, `claude`'s `theme` key).

Changing theme means editing nine files. Worse, the two machines have drifted:
Omarchy's Catppuccin is blue-accented, and the macOS side grew a mauve accent,
so the same named theme looks different on each machine.

## Approach

Mirror what Omarchy actually does, which is not what it appears to do from the
outside.

Omarchy themes almost nothing per-application. Its `tmux.conf` theme block is
pure ANSI names (`fg=blue`, `fg=brightblack`), its `starship.toml` uses
`bold cyan`, its `herdr` config sets `name = "terminal"` with
`accent = "blue"`, its `lazygit/config.yml` is empty, and it ships no `jj`
config and no `FZF_DEFAULT_OPTS` at all. The palette lives in exactly one
place — the terminal — and every ANSI-capable tool inherits it for free. Only
tools that cannot read ANSI colours get an explicit theme file: `neovim.lua`,
`claude.json`, `btop`, `vscode`.

So the design is not "extract the hexes into fragments". It is: give the
terminal the palette, delete the rest, and keep theme files only for the three
tools that genuinely need one.

Two consequences follow. The theme directory stays small enough to be
comprehensible — four files, not nine. And parity with Omarchy becomes
structural rather than a thing to re-audit, because the macOS configs stop
expressing colour at all.

## The theme package

A new top-level stow package, `theme`, macOS-only. Omarchy owns this territory
on Linux and the repo does not fight it.

```
theme/.config/theme/
├── catppuccin/
│   ├── colors.toml     # Omarchy's themes/catppuccin/colors.toml, verbatim
│   ├── ghostty.conf    # 16-colour palette + bg/fg/cursor/selection
│   ├── neovim.lua      # LazyVim plugin spec (plugin + colorscheme)
│   └── claude.json     # Claude Code custom theme
└── current -> catppuccin
```

`current` is a tracked symlink, so a fresh `stow theme` lands working and the
active theme is visible in git. Switching themes is `ln -sfn <name> current`
inside the repo plus a commit. There is no `theme set` script; adding one later
is easy, because only these four files would ever need swapping.

The repo owns all of `~/.config/theme`, so stow may fold it. No `--no-folding`,
consistent with every other macOS package.

### colors.toml is carried but not consumed

Nothing on macOS reads `colors.toml`. It is the palette of record: it lets the
three generated files be re-derived, and it gives a future `theme set` script
something to render from. It also keeps the theme directory comparable
file-for-file with Omarchy's.

### The three files are generated, not transcribed

Omarchy's own renderer produces `ghostty.conf`, `neovim.lua` and `claude.json`,
run against a throwaway `HOME` so it cannot touch the live
`~/.local/state/omarchy/`:

```sh
HOME=<scratch> OMARCHY_PATH=/usr/share/omarchy \
  PATH="$PATH:/usr/share/omarchy/bin" omarchy-theme-set-templates
```

This gives byte-exact parity with Linux rather than a hand transcription of
fifty hex values and the template `mix` functions. One edit afterwards:
`claude.json`'s `"name"` becomes `"Catppuccin"` instead of `"Omarchy"`.

## Per-tool changes

### Wired to the theme directory

**ghostty** — `theme = Catppuccin Mocha` becomes
`config-file = ?"~/.config/theme/current/ghostty.conf"`. The `?` prefix makes a
missing theme package non-fatal. Font, `macos-option-as-alt` and all keybinds
are untouched; those are platform choices, not theme.

**nvim** — `lua/plugins/catppuccin.lua` is replaced by `lua/plugins/theme.lua`,
which reads the theme's `neovim.lua` through a guarded `dofile`. If
`~/.config/theme` is absent the spec degrades to LazyVim's default colorscheme
rather than erroring at startup.

Omarchy's catppuccin theme sets `colorscheme = "catppuccin-nvim"`. This is a
real colorscheme: the plugin ships `colors/catppuccin-nvim.vim`, whose entire
body is `lua require("catppuccin").load()`, so it loads whichever flavour the
plugin is configured for — mocha by default. It is used as-is. Today our nvim
sets no colorscheme at all, so this is also a small behaviour gain.

**claude** — `themes/catppuccin-mocha.json` is deleted and replaced by a
relative symlink `themes/theme.json` pointing at
`../../../theme/.config/theme/current/claude.json`; `settings.json` gets
`"theme": "custom:theme"`. The accent moves mauve → blue, matching Omarchy's
`claude.json`. Three levels of `..` are needed, not two: stow replaces
`claude/.claude/themes/theme.json` with a symlink *inside the repo*, so the
stored relative target resolves from `<repo>/claude/.claude/themes/`, not
from `$HOME`; two `..` would land on `<repo>/claude/.config/…`, which
doesn't exist.

### Rewritten to ANSI, adopting Omarchy's config

**tmux** — drop the `catppuccin/tmux` plugin and every `@catppuccin_*` option,
and adopt Omarchy's status-bar and theme blocks verbatim: `status-style
bg=default,fg=default`, the blue `status-left` session chip, `brightblack` and
`blue` window formats, pane border styles, `message-style`, `mode-style`,
`clock-mode-colour`. Keeps the existing TPM set (tpm, sensible, resurrect,
continuum) and every keybinding from `d40480c`. Gains Omarchy's
`automatic-rename` to `#{b:pane_current_path}` and `set-titles`.

After deploying, `~/.tmux/plugins/catppuccin` should be removed by hand.

**herdr** — `[theme] name = "catppuccin"` becomes `name = "terminal"`, plus
`[theme.custom] panel_bg = "black"` and `[ui] accent = "blue"`, and Omarchy's
chrome keys `pane_gaps`, `pane_outer_borders` and `pane_scrollbars` set to
false. Keybindings stay exactly as they are — aligning those was a deliberate
decision in `d40480c` and is not theme.

**starship** — replaced by Omarchy's `starship.toml` verbatim. This is a
functional change, not only a visual one, and it is accepted deliberately: the
Omarchy prompt drops `cmd_duration`, the `python` virtualenv indicator,
`username`, and `hostname` (the SSH indicator), drops the two-line
`line_break`, and turns `add_newline` back on. It carries no hex values at all,
using `bold cyan` and `italic cyan` instead.

This supersedes the prompt defined in
`docs/superpowers/specs/2026-09-16-lean-zsh-starship-design.md`. That spec stays
in place as the record of why the lean prompt existed; it is not rewritten.

Because the file is a copy of Omarchy's rather than a delta against it, it will
not track upstream changes to Omarchy's `starship.toml`. That is accepted.

### Colour blocks deleted

**jj** — the entire `[colors]` block is removed. jj's own defaults are
ANSI-named, so it follows the terminal palette automatically. `[user]` and
`[ui]` stay.

**zsh/.fzf.zsh** — the `FZF_DEFAULT_OPTS` Catppuccin block is removed. Omarchy
sets no fzf colours at all, and fzf's defaults are ANSI. The PATH setup,
completion and key-bindings sourcing stay.

**lazygit** — Omarchy's `lazygit/config.yml` is empty, so the theme block
leaves nothing behind. The whole `lazygit` stow package is deleted rather than
stowing an empty file. `brew "lazygit"` stays in `Brewfile.optional`: the tool
is still used, it just stops being configured.

## Documentation

`README.md` — drop the `lazygit` row, add a `theme` row, fix both `stow`
example command lines, and update the paragraph listing which macOS packages
Omarchy supersedes.

`CLAUDE.md` — the same package-list edits, and the conventions bullet
"Catppuccin Mocha is the consistent theme across tmux, fzf, ghostty, lazygit,
jj, and neovim — on macOS" is replaced by the rule this change encodes:

> The terminal carries the palette. `theme/` holds one directory per theme and
> a tracked `current` symlink; only tools that cannot read ANSI colours
> (ghostty, neovim, Claude Code) get a file there, and they include it from
> `~/.config/theme/current/`. Everything else uses ANSI colour names and
> inherits the terminal's palette for free. Adding a tool means checking
> whether it reads ANSI before theming it — usually the answer is that it needs
> no theme config at all.

## Verification

There is no test framework in this repo, but most of this is mechanically
checkable, because `ghostty`, `tmux`, `starship`, `fzf`, `nvim` and `lazygit`
are installed on the Linux machine even though the deployment target is macOS.

- `stow -n -v theme` and a dry run of every touched package: clean, no conflicts
- `grep -rIn 'catppuccin\|#[0-9a-fA-F]\{6\}'` across all packages: hits only
  under `theme/`
- the three generated files byte-compare equal to a fresh render from Omarchy's
  templates, modulo the one `"name"` edit
- `tmux -f tmux/.tmux.conf new-session -d` loads with no errors, then is killed
- `ghostty +show-config` against the new config resolves the include
- `STARSHIP_CONFIG=starship/.config/starship.toml starship prompt` renders
- the nvim guarded `dofile` falls back cleanly when `~/.config/theme` is absent

`jj` is not installed on the Linux machine, so the `[colors]` deletion is
verified by config parse on the Mac.

## Out of scope

No `theme set` script. No Linux-side changes and no edits to the `omarchy`
package. No keybinding changes. Omarchy's `git` config differences stay
unreconciled — they are not theme. Only Catppuccin is supported; the directory
layout admits more themes but none are added.
