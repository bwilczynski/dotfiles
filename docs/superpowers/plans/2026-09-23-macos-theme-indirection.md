# macOS Theme Indirection Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace hardcoded Catppuccin values across nine macOS stow packages with a single `theme` package that three tools include, deleting the colour configuration of the six tools that can read ANSI colours instead.

**Architecture:** The terminal carries the palette. A new `theme` stow package holds one directory per theme plus a tracked `current` symlink; only ghostty, Neovim and Claude Code — the tools that cannot read ANSI colours — get a file there. tmux, starship, herdr, jj, fzf and lazygit are rewritten to ANSI colour names or stripped entirely, adopting Omarchy's configuration so both machines match.

**Tech Stack:** GNU Stow, plain config files (TOML, YAML, JSON, Lua, tmux.conf, zsh). No build system, no test framework.

**Spec:** `docs/superpowers/specs/2026-09-23-macos-theme-indirection-design.md`

## Global Constraints

- Branch is `feat/macos-theme-indirection`. Do not merge or push; the branch is reviewed at the end.
- Repo lives at `~/.dotfiles`, so stow's target is `$HOME` and no `-t` flag is ever used.
- macOS packages may be folded by stow. Do **not** add `--no-folding`; that rule applies only to the Linux packages.
- No tracked file may contain an absolute path. Machine-local settings go in the untracked tail files (`~/.zshrc.custom`, `~/.gitconfig.local`).
- After this change, the only tracked files containing a hex colour or the string `catppuccin` are under `theme/`. The two root documents (`README.md`, `CLAUDE.md`) may name the theme in prose.
- Every config change is verified by running the tool's own parser where that tool is installed on this Linux machine. `jj` is **not** installed here; its change is verified by inspection and deferred to the Mac.
- Commit after every task. Commit messages follow the existing Conventional Commits style (`feat(scope):`, `refactor(scope):`, `docs:`) and end with the `Co-Authored-By: Claude Opus 5 <noreply@anthropic.com>` trailer.

**Why there are no unit tests:** this repository has no test framework and no application code — it is configuration consumed by other programs. The test-first discipline is preserved by making each task run a *verification command that fails before the change and passes after*, using each tool's real parser. Where a tool has no parser to invoke, the check is a `grep` assertion over the tracked tree. Never skip the "verify it fails first" step; it is what proves the check has teeth.

---

### Task 1: Create the theme package

**Files:**
- Create: `theme/.config/theme/catppuccin/colors.toml`
- Create: `theme/.config/theme/catppuccin/ghostty.conf`
- Create: `theme/.config/theme/catppuccin/neovim.lua`
- Create: `theme/.config/theme/catppuccin/claude.json`
- Create: `theme/.config/theme/current` (symlink → `catppuccin`)

**Interfaces:**
- Consumes: nothing.
- Produces: the paths `~/.config/theme/current/ghostty.conf`, `~/.config/theme/current/neovim.lua`, `~/.config/theme/current/claude.json` once stowed. Tasks 2, 3 and 4 depend on these exact names.

The four file contents below were produced by running Omarchy's own template renderer against `/usr/share/omarchy/themes/catppuccin/` in a throwaway `HOME`. They are reproduced verbatim so that no transcription is needed. The only deviation from Omarchy's output is `claude.json`'s `"name"` field, which reads `"Catppuccin"` instead of `"Omarchy"`.

- [ ] **Step 1: Verify the package does not exist yet**

Run: `ls theme 2>&1`
Expected: `ls: cannot access 'theme': No such file or directory`

- [ ] **Step 2: Create the directory**

```bash
mkdir -p theme/.config/theme/catppuccin
```

- [ ] **Step 3: Write `theme/.config/theme/catppuccin/colors.toml`**

```toml
mode = "dark"

accent = "#89b4fa"
selection = "#45475a"
muted = "#585b70"

background = "#1e1e2e"
dark_background = "#161622"
darker_background = "#101019"
lighter_background = "#313244"

foreground = "#cdd6f4"
dark_foreground = "#6c7086"
light_foreground = "#bac2de"
bright_foreground = "#cdd6f4"

red = "#f38ba8"
yellow = "#f9e2af"
orange = "#f6b6ab"
green = "#a6e3a1"
cyan = "#94e2d5"
blue = "#89b4fa"
magenta = "#f5c2e7"
brown = "#7b5b55"

bright_red = "#f38ba8"
bright_yellow = "#f9e2af"
bright_green = "#a6e3a1"
bright_cyan = "#94e2d5"
bright_blue = "#89b4fa"
bright_magenta = "#f5c2e7"
```

- [ ] **Step 4: Write `theme/.config/theme/catppuccin/ghostty.conf`**

```
background = #1e1e2e
foreground = #cdd6f4
cursor-color = #cdd6f4
selection-background = #45475a
selection-foreground = #cdd6f4

palette = 0=#1e1e2e
palette = 1=#f38ba8
palette = 2=#a6e3a1
palette = 3=#f9e2af
palette = 4=#89b4fa
palette = 5=#f5c2e7
palette = 6=#94e2d5
palette = 7=#cdd6f4
palette = 8=#585b70
palette = 9=#f38ba8
palette = 10=#a6e3a1
palette = 11=#f9e2af
palette = 12=#89b4fa
palette = 13=#f5c2e7
palette = 14=#94e2d5
palette = 15=#cdd6f4
```

- [ ] **Step 5: Write `theme/.config/theme/catppuccin/neovim.lua`**

`catppuccin-nvim` is a real colorscheme: the plugin ships `colors/catppuccin-nvim.vim`, whose whole body is `lua require("catppuccin").load()`, so it loads the plugin's configured flavour — mocha by default. Do not substitute `catppuccin-mocha`.

```lua
return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin-nvim",
    },
  },
}
```

- [ ] **Step 6: Write `theme/.config/theme/catppuccin/claude.json`**

```json
{
  "name": "Catppuccin",
  "base": "dark",
  "overrides": {
    "claude": "#89b4fa",
    "claudeShimmer": "#a1c0f8",
    "text": "#cdd6f4",
    "inverseText": "#1e1e2e",
    "inactive": "#878ca5",
    "inactiveShimmer": "#a1a8c3",
    "subtle": "#585b70",
    "suggestion": "#94e2d5",
    "permission": "#89b4fa",
    "permissionShimmer": "#a1c0f8",
    "remember": "#f9e2af",
    "success": "#a6e3a1",
    "error": "#f38ba8",
    "warning": "#f9e2af",
    "warningShimmer": "#eadec7",
    "merged": "#f5c2e7",
    "promptBorder": "#89b4fa",
    "promptBorderShimmer": "#a1c0f8",
    "planMode": "#94e2d5",
    "autoAccept": "#f9e2af",
    "bashBorder": "#f9e2af",
    "ide": "#94e2d5",
    "diffAdded": "#323c3f",
    "diffRemoved": "#3e2e40",
    "diffAddedDimmed": "#292e37",
    "diffRemovedDimmed": "#2f2738",
    "diffAddedWord": "#4a5d53",
    "diffRemovedWord": "#624155",
    "userMessageBackground": "#29293a",
    "userMessageBackgroundHover": "#303042",
    "bashMessageBackgroundColor": "#29293a",
    "memoryBackgroundColor": "#29293a",
    "selectionBg": "#45475a",
    "rate_limit_fill": "#89b4fa",
    "rate_limit_empty": "#414356",
    "briefLabelYou": "#f9e2af",
    "briefLabelClaude": "#89b4fa"
  }
}
```

- [ ] **Step 7: Create the `current` symlink**

The target is the bare directory name, so it resolves whether or not stow folds `~/.config/theme`.

```bash
ln -s catppuccin theme/.config/theme/current
```

- [ ] **Step 8: Verify the files parse and the symlink resolves**

```bash
ghostty +validate-config --config-file=theme/.config/theme/catppuccin/ghostty.conf; echo "ghostty=$?"
python3 -c "import json;json.load(open('theme/.config/theme/catppuccin/claude.json'))"; echo "json=$?"
nvim --headless -c "lua assert(type(dofile('theme/.config/theme/catppuccin/neovim.lua'))=='table')" -c qa; echo "lua=$?"
readlink theme/.config/theme/current
test -f theme/.config/theme/current/colors.toml; echo "symlink=$?"
```

Expected: `ghostty=0`, `json=0`, `lua=0`, `catppuccin`, `symlink=0`.

- [ ] **Step 9: Verify stow would deploy it cleanly**

Run: `stow -n -v theme 2>&1`
Expected: output mentioning `LINK: .config/theme => ../.dotfiles/theme/.config/theme` (or per-file LINK lines), and **no** line containing `CONFLICT` or `WARNING`.

- [ ] **Step 10: Commit**

```bash
git add theme
git commit -m "$(cat <<'EOF'
feat(theme): add theme package with Catppuccin

Holds one directory per theme plus a tracked `current` symlink. The
three files are Omarchy's own rendered output for its catppuccin theme,
so both machines draw from identical values.

Co-Authored-By: Claude Opus 5 <noreply@anthropic.com>
EOF
)"
```

---

### Task 2: Point ghostty at the theme

**Files:**
- Modify: `ghostty/.config/ghostty/config:2`

**Interfaces:**
- Consumes: `~/.config/theme/current/ghostty.conf` from Task 1.
- Produces: nothing other tasks depend on.

- [ ] **Step 1: Verify the hardcoded theme is present and the include is not**

Run: `grep -n 'theme\|config-file' ghostty/.config/ghostty/config`
Expected: exactly one match, `2:theme = Catppuccin Mocha`.

- [ ] **Step 2: Replace the theme line with the include**

Replace line 2, `theme = Catppuccin Mocha`, with:

```
config-file = ?"~/.config/theme/current/ghostty.conf"
```

The `?` prefix makes a missing file non-fatal, so the config still loads on a machine where the `theme` package was not stowed. Leave `font-family`, `macos-option-as-alt` and every `keybind` untouched — those are platform choices, not theme.

The first three lines of the file should now read:

```
font-family = Fira Code Nerd Font Mono
config-file = ?"~/.config/theme/current/ghostty.conf"

```

- [ ] **Step 3: Verify the config still parses**

Run: `ghostty +validate-config --config-file=ghostty/.config/ghostty/config; echo "exit=$?"`
Expected: `exit=0`

- [ ] **Step 4: Verify the hardcoded theme is gone**

Run: `grep -ci catppuccin ghostty/.config/ghostty/config`
Expected: `0`

- [ ] **Step 5: Commit**

```bash
git add ghostty
git commit -m "$(cat <<'EOF'
refactor(ghostty): include the current theme's palette

Replaces the built-in `theme = Catppuccin Mocha` with an optional
include of ~/.config/theme/current/ghostty.conf, so the terminal
palette follows the theme package.

Co-Authored-By: Claude Opus 5 <noreply@anthropic.com>
EOF
)"
```

---

### Task 3: Point Neovim at the theme

**Files:**
- Delete: `nvim/.config/nvim/lua/plugins/catppuccin.lua`
- Create: `nvim/.config/nvim/lua/plugins/theme.lua`

**Interfaces:**
- Consumes: `~/.config/theme/current/neovim.lua` from Task 1, which returns a LazyVim plugin spec table.
- Produces: nothing other tasks depend on.

Note (recorded after the fact): this task's hardcoded-colour audit covered
only `nvim/.config/nvim/lua/plugins/`. `lua/config/lazy.lua` also had a
hardcoded `vim.cmd.colorscheme("catppuccin-mocha")` call, which this audit
missed and which had to be removed later, in commit bc28880 (amended to
fc83061). `lua/config/` must be audited too, not just `lua/plugins/`.

- [ ] **Step 1: Verify the current plugin file names the theme**

Run: `cat nvim/.config/nvim/lua/plugins/catppuccin.lua`
Expected:
```lua
return {
  { "catppuccin/nvim", name = "catppuccin", priority = 1000 },
}
```
Note that it installs the plugin but never sets a colorscheme, so Neovim currently falls back to LazyVim's default.

- [ ] **Step 2: Delete the old file and write the replacement**

```bash
git rm -q nvim/.config/nvim/lua/plugins/catppuccin.lua
```

Create `nvim/.config/nvim/lua/plugins/theme.lua`:

```lua
-- The active theme supplies both the colorscheme plugin and the colorscheme
-- name. See the `theme` stow package. Without it, LazyVim's default is used.
local spec = vim.fn.expand("~/.config/theme/current/neovim.lua")

if (vim.uv or vim.loop).fs_stat(spec) then
  return dofile(spec)
end

return {}
```

`vim.uv` is the modern name and `vim.loop` the older one; the `or` keeps this working on either.

- [ ] **Step 3: Verify the guarded path returns a table when the theme is absent**

This proves the fallback works, which is the part that would otherwise break Neovim startup on a machine without the `theme` package.

```bash
nvim --headless -c "lua local f=loadfile('nvim/.config/nvim/lua/plugins/theme.lua'); assert(type(f())=='table')" -c qa; echo "exit=$?"
```

Expected: `exit=0`

- [ ] **Step 4: Verify it loads the real spec when the theme is present**

```bash
mkdir -p ~/.config/theme
ln -sfn "$PWD/theme/.config/theme/catppuccin" ~/.config/theme/current
nvim --headless -c "lua local s=dofile('nvim/.config/nvim/lua/plugins/theme.lua'); assert(#s==2, 'expected 2 plugin specs, got '..#s)" -c qa; echo "exit=$?"
rm ~/.config/theme/current; rmdir ~/.config/theme 2>/dev/null
```

Expected: `exit=0`

This temporarily creates `~/.config/theme/current` on the Linux box to exercise the loaded path, then removes it. It does not stow anything and does not touch Omarchy's config.

- [ ] **Step 5: Commit**

```bash
git add nvim
git commit -m "$(cat <<'EOF'
refactor(nvim): load the colorscheme from the theme package

Replaces the hardcoded catppuccin plugin spec with a guarded dofile of
the current theme's neovim.lua, falling back to LazyVim's default when
the theme package is not stowed. Also sets a colorscheme for the first
time; previously the plugin was installed but never activated.

Co-Authored-By: Claude Opus 5 <noreply@anthropic.com>
EOF
)"
```

---

### Task 4: Point Claude Code at the theme

**Files:**
- Delete: `claude/.claude/themes/catppuccin-mocha.json`
- Create: `claude/.claude/themes/theme.json` (symlink)
- Modify: `claude/.claude/settings.json` (the `theme` key)

**Interfaces:**
- Consumes: `theme/.config/theme/current/claude.json` from Task 1.
- Produces: nothing other tasks depend on.

**The symlink target is repo-relative, and this matters.** Stow replaces the file at `~/.claude/themes/theme.json` with a symlink into the repo, so a stored target of `../../.config/theme/current/claude.json` would be resolved relative to `~/.dotfiles/claude/.claude/themes/` — not relative to `$HOME` — and would dangle. The target must therefore climb out of the `claude` package and into the `theme` package: `../../../theme/.config/theme/current/claude.json`.

- [ ] **Step 1: Verify the current state**

```bash
ls claude/.claude/themes/
grep -n '"theme"' claude/.claude/settings.json
```

Expected: `catppuccin-mocha.json`, and a line reading `"theme": "custom:catppuccin-mocha",`.

- [ ] **Step 2: Replace the theme file with a symlink**

```bash
git rm -q claude/.claude/themes/catppuccin-mocha.json
ln -s ../../../theme/.config/theme/current/claude.json claude/.claude/themes/theme.json
```

- [ ] **Step 3: Update the theme key in `claude/.claude/settings.json`**

Change `"theme": "custom:catppuccin-mocha",` to:

```json
  "theme": "custom:theme",
```

Leave every other key in the file untouched.

- [ ] **Step 4: Verify the symlink resolves to real JSON and the setting matches**

```bash
test -f claude/.claude/themes/theme.json; echo "resolves=$?"
python3 -c "import json;print(json.load(open('claude/.claude/themes/theme.json'))['name'])"
python3 -c "import json;print(json.load(open('claude/.claude/settings.json'))['theme'])"
```

Expected: `resolves=0`, `Catppuccin`, `custom:theme`.

The theme file's basename (`theme.json`) must match the setting's suffix (`custom:theme`); Claude Code resolves `custom:NAME` to `~/.claude/themes/NAME.json`.

- [ ] **Step 5: Verify stow would deploy the symlink without conflict**

Run: `stow -n -v claude 2>&1 | grep -i 'conflict\|warning'; echo "clean=$?"`
Expected: `clean=1` (grep found nothing).

- [ ] **Step 6: Commit**

```bash
git add claude
git commit -m "$(cat <<'EOF'
refactor(claude): follow the theme package's Claude Code theme

Replaces the hand-written catppuccin-mocha.json with a symlink to the
current theme's claude.json. The target is repo-relative because stow
resolves it from the package, not from $HOME. Accent moves mauve to
blue, matching Omarchy.

Co-Authored-By: Claude Opus 5 <noreply@anthropic.com>
EOF
)"
```

---

### Task 5: Rewrite tmux to ANSI colours

**Files:**
- Modify: `tmux/.tmux.conf:1-33` (the header, plugin list and status-line block)

**Interfaces:**
- Consumes: nothing.
- Produces: nothing other tasks depend on.

This drops the `catppuccin/tmux` plugin and adopts Omarchy's status-bar and theme blocks verbatim. Every keybinding below line 33 stays exactly as it is — those were aligned deliberately in `d40480c`.

- [ ] **Step 1: Verify the catppuccin plugin and options are present**

Run: `grep -c catppuccin tmux/.tmux.conf`
Expected: `8`

- [ ] **Step 2: Replace the top of the file**

Replace everything from line 1 through the line `set -ag status-right "#{E:@catppuccin_status_session}"` (inclusive) with:

```tmux
set -g base-index 1
set -g renumber-windows on

# Options to make tmux more pleasant
set -g mouse on
set -g default-terminal "tmux-256color"

# Plugins
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-sensible'
set -g @plugin 'tmux-plugins/tmux-resurrect'
set -g @plugin 'tmux-plugins/tmux-continuum'

# Session management
set -g @continuum-restore 'on'

# Status bar
set -g status-position top
set -g status-interval 5
set -g status-left-length 30
set -g status-right-length 50
set -g window-status-separator ""
set -gw automatic-rename on
set -gw automatic-rename-format '#{b:pane_current_path}'
set -g set-titles on
set -g set-titles-string '#h:#W'

# Theme. ANSI names only; the terminal supplies the palette, so this follows
# whatever ~/.config/theme/current is set to without naming a colour scheme.
set -g status-style "bg=default,fg=default"
set -g status-left "#[fg=black,bg=blue,bold] #S #[bg=default] "
set -g status-right "#[fg=blue]#{?pane_in_mode,COPY ,}#{?client_prefix,PREFIX ,}#{?window_zoomed_flag,ZOOM ,}#[fg=brightblack]#h "
set -g window-status-format "#[fg=brightblack] #I:#W "
set -g window-status-current-format "#[fg=blue,bold] #I:#W "
set -g pane-border-style "fg=brightblack"
set -g pane-active-border-style "fg=blue"
set -g message-style "bg=default,fg=blue"
set -g message-command-style "bg=default,fg=blue"
set -g mode-style "bg=blue,fg=black"
setw -g clock-mode-colour blue
```

Note `status-position top` moved from line 3 into the new "Status bar" block; make sure it appears exactly once in the finished file.

- [ ] **Step 3: Verify the config loads in real tmux**

```bash
tmux -f tmux/.tmux.conf -L themecheck new-session -d 2>&1; echo "exit=$?"
tmux -L themecheck kill-server 2>/dev/null
```

Expected: `exit=0` with no error output. A syntax error would print `.tmux.conf:N: unknown command` and return non-zero.

- [ ] **Step 4: Verify catppuccin is gone and `status-position` is not duplicated**

```bash
grep -ci catppuccin tmux/.tmux.conf
grep -c 'status-position' tmux/.tmux.conf
```

Expected: `0` and `1`.

- [ ] **Step 5: Commit**

```bash
git add tmux
git commit -m "$(cat <<'EOF'
refactor(tmux): adopt Omarchy's ANSI status line

Drops the catppuccin/tmux plugin and its options in favour of Omarchy's
status-bar and theme blocks, which use ANSI colour names and so inherit
the terminal's palette. Keybindings are unchanged.

Run `rm -rf ~/.tmux/plugins/catppuccin` after deploying.

Co-Authored-By: Claude Opus 5 <noreply@anthropic.com>
EOF
)"
```

---

### Task 6: Rewrite herdr to the terminal theme

**Files:**
- Modify: `herdr/.config/herdr/config.toml` (the `[theme]` block near the top and the `[ui]` block near the bottom)

**Interfaces:**
- Consumes: nothing.
- Produces: nothing other tasks depend on.

Keybindings stay exactly as they are; only the theme and window-chrome keys change.

- [ ] **Step 1: Verify the current theme block**

Run: `grep -n -A3 '^\[theme\]\|^\[ui\]' herdr/.config/herdr/config.toml`
Expected: a `[theme]` block with `name = "catppuccin"`, and a `[ui]` block with `prompt_new_tab_name` and `confirm_close`.

- [ ] **Step 2: Replace the `[theme]` block**

Replace:

```toml
[theme]
# Catppuccin Mocha, matching Ghostty, tmux, fzf, and Neovim.
name = "catppuccin"
```

with:

```toml
[theme]
# The terminal supplies the palette; herdr draws on ANSI colours, so this
# follows whatever ~/.config/theme/current is set to.
name = "terminal"

[theme.custom]
# The active tab is drawn as panel_bg text on an accent background, so panel_bg
# has to be dark for it to read.
panel_bg = "black"
```

- [ ] **Step 3: Replace the `[ui]` block**

Replace:

```toml
[ui]
# Match Omarchy: create tabs immediately and close without confirmation.
prompt_new_tab_name = false
confirm_close = false
```

with:

```toml
[ui]
accent = "blue"

# Match Omarchy: create tabs immediately and close without confirmation.
prompt_new_tab_name = false
confirm_close = false

# Single-line dividers between adjacent panes and no outer frame
pane_gaps = false
pane_outer_borders = false

# No scrollbar column beside the panes
pane_scrollbars = false
```

Leave the trailing `[ui.toast]` block untouched.

- [ ] **Step 4: Verify the file is still valid TOML and names no theme**

```bash
python3 -c "import tomllib;d=tomllib.load(open('herdr/.config/herdr/config.toml','rb'));print(d['theme']['name'], d['ui']['accent'])"
grep -ci catppuccin herdr/.config/herdr/config.toml
```

Expected: `terminal blue` and `0`.

- [ ] **Step 5: Commit**

```bash
git add herdr
git commit -m "$(cat <<'EOF'
refactor(herdr): use the terminal theme with a blue accent

Matches Omarchy's herdr config: the built-in "terminal" theme draws on
ANSI colours, so herdr follows the terminal's palette. Also adopts
Omarchy's pane chrome. Keybindings are unchanged.

Co-Authored-By: Claude Opus 5 <noreply@anthropic.com>
EOF
)"
```

---

### Task 7: Replace starship.toml with Omarchy's

**Files:**
- Modify: `starship/.config/starship.toml` (replaced wholesale)

**Interfaces:**
- Consumes: nothing.
- Produces: nothing other tasks depend on.

**This is a deliberate functional change, not only a visual one.** Omarchy's prompt drops `cmd_duration`, the `python` virtualenv indicator, `username`, `hostname` (the SSH indicator) and the two-line `line_break`, and turns `add_newline` back on. The spec records this as accepted. Do not merge the two configs or reinstate the dropped modules; that decision was made explicitly.

- [ ] **Step 1: Verify the current file carries a hex palette**

Run: `grep -c '#[0-9a-f]\{6\}' starship/.config/starship.toml`
Expected: `6`

- [ ] **Step 2: Replace the whole file**

Copy `/usr/share/omarchy/config/starship.toml` byte-for-byte to
`starship/.config/starship.toml` (e.g. `cp /usr/share/omarchy/config/starship.toml
starship/.config/starship.toml`). Do not retype it from the listing below: the
`git_status` table's `conflicted`, `up_to_date`, and `modified` values contain
Nerd Font glyphs in the private use area, and those glyphs cannot be
transcribed through this document — they did not survive being pasted into
this plan and show below as bare `" "`. The listing is illustrative only, to
show the file's shape; the shipped config (copied byte-for-byte from Omarchy)
is correct.

```toml
add_newline = true
command_timeout = 200
format = "[$directory$git_branch$git_status]($style)$character"

[character]
error_symbol = "[✗](bold cyan)"
success_symbol = "[❯](bold cyan)"

[directory]
truncation_length = 2
truncation_symbol = "…/"
repo_root_style = "bold cyan"
repo_root_format = "[$repo_root]($repo_root_style)[$path]($style)[$read_only]($read_only_style) "

[git_branch]
format = "[$branch]($style) "
style = "italic cyan"

[git_status]
format     = '[$all_status]($style)'
style      = "cyan"
ahead      = "⇡${count} "
diverged   = "⇕⇡${ahead_count}⇣${behind_count} "
behind     = "⇣${count} "
conflicted = " "
up_to_date = " "
untracked  = "? "
modified   = " "
stashed    = ""
staged     = ""
renamed    = ""
deleted    = ""
```

- [ ] **Step 3: Verify starship renders the prompt with no hexes**

```bash
STARSHIP_CONFIG=starship/.config/starship.toml starship prompt | cat -v | grep -c '38;2;'; echo "---"
STARSHIP_CONFIG=starship/.config/starship.toml starship prompt
```

Expected: the count is `0` — before this change it was non-zero, because the hex palette emitted 24-bit `38;2;R;G;B` escapes. Now only ANSI escapes appear, which is exactly what makes the prompt follow the terminal palette. The prompt itself should render a truncated path, the branch name, and a `❯`.

- [ ] **Step 4: Verify no hexes remain in the file**

Run: `grep -c '#[0-9a-f]\{6\}' starship/.config/starship.toml`
Expected: `0`

- [ ] **Step 5: Commit**

```bash
git add starship
git commit -m "$(cat <<'EOF'
refactor(starship): adopt Omarchy's prompt

Replaces the lean prompt and its Catppuccin palette with Omarchy's
starship.toml, which carries no hex values and so follows the
terminal's palette. Supersedes the prompt in
docs/superpowers/specs/2026-09-16-lean-zsh-starship-design.md; drops
cmd_duration, virtualenv, username and the SSH hostname indicator.

Co-Authored-By: Claude Opus 5 <noreply@anthropic.com>
EOF
)"
```

---

### Task 8: Delete the jj and fzf colour blocks

**Files:**
- Modify: `jj/.config/jj/config.toml` (remove the `[colors]` block)
- Modify: `zsh/.fzf.zsh` (remove the `FZF_DEFAULT_OPTS` block)

**Interfaces:**
- Consumes: nothing.
- Produces: nothing other tasks depend on.

Both tools' own defaults use ANSI colour names, so deleting these blocks makes them follow the terminal palette. Nothing replaces them.

- [ ] **Step 1: Verify both colour blocks are present**

```bash
grep -c '#[0-9a-f]\{6\}' jj/.config/jj/config.toml
grep -c '#[0-9A-F]\{6\}' zsh/.fzf.zsh
```

Expected: `99` and `5`.

- [ ] **Step 2: Truncate `jj/.config/jj/config.toml`**

Delete the comment line `# Catppuccin Mocha — mirrors jj's default semantic colors with palette hexes`, the `[colors]` header, and every line after it to the end of the file. The finished file is exactly:

```toml
#:schema https://docs.jj-vcs.dev/latest/config-schema.json

[user]
name = "Bartłomiej Wilczyński"
email = "me@bwilczynski.com"

[ui]
default-command = "log"
diff-formatter = ["difft", "--color=always", "$left", "$right"]
```

- [ ] **Step 3: Remove the fzf colour block from `zsh/.fzf.zsh`**

Delete the comment `# Catppuccin fzf theme` and the whole `export FZF_DEFAULT_OPTS=" \ ... "` statement including its closing quote. The finished file is exactly:

```zsh
# Setup fzf
if [[ ! "$PATH" == */opt/homebrew/opt/fzf/bin* ]]; then
  export PATH="$PATH:/opt/homebrew/opt/fzf/bin"
fi

# Auto-completion
[[ $- == *i* ]] && source "/opt/homebrew/opt/fzf/shell/completion.zsh" 2> /dev/null

# Key bindings
source "/opt/homebrew/opt/fzf/shell/key-bindings.zsh"
```

- [ ] **Step 4: Verify both files parse and carry no colour**

```bash
python3 -c "import tomllib;d=tomllib.load(open('jj/.config/jj/config.toml','rb'));assert 'colors' not in d;print('jj ok', list(d))"
zsh -n zsh/.fzf.zsh; echo "zsh-syntax=$?"
grep -cil 'catppuccin\|#[0-9a-f]\{6\}' jj/.config/jj/config.toml zsh/.fzf.zsh
```

Expected: `jj ok ['user', 'ui']`, `zsh-syntax=0`, and `0` from grep (it prints nothing and returns 1; the count of matching files is zero).

`jj` itself is not installed on this Linux machine, so the TOML parse above is the strongest available check. Confirm with `jj config list` on the Mac after deploying.

- [ ] **Step 5: Commit**

```bash
git add jj zsh
git commit -m "$(cat <<'EOF'
refactor(jj,zsh): drop hardcoded palettes

Both jj and fzf default to ANSI colour names, so removing these blocks
makes them follow the terminal's palette. Omarchy configures neither.

Co-Authored-By: Claude Opus 5 <noreply@anthropic.com>
EOF
)"
```

---

### Task 9: Delete the lazygit package

**Files:**
- Delete: `lazygit/Library/Application Support/lazygit/config.yml` (and the now-empty `lazygit/` tree)

**Interfaces:**
- Consumes: nothing.
- Produces: the absence of the `lazygit` package, which Task 10 documents.

The file contains nothing but the Catppuccin theme, and Omarchy's equivalent is an empty file, so removing the theme leaves an empty package. `brew "lazygit"` stays in `Brewfile.optional` — the tool is still used, it just stops being configured. Do not touch the Brewfiles.

- [ ] **Step 1: Verify the package contains only theme configuration**

```bash
find lazygit -type f
grep -c '#[0-9a-f]\{6\}' "lazygit/Library/Application Support/lazygit/config.yml"
```

Expected: the single path `lazygit/Library/Application Support/lazygit/config.yml`, and `13`.

- [ ] **Step 2: Confirm lazygit is currently stowed or not, then remove the package**

If the package is deployed on this machine, unstow it first so no dangling symlink is left behind. On Linux it will not be deployed, and `stow -D` is a harmless no-op.

```bash
stow -D lazygit 2>/dev/null || true
git rm -q -r lazygit
```

- [ ] **Step 3: Verify the package is gone and the Brewfile still installs the tool**

```bash
ls lazygit 2>&1
grep -n lazygit Brewfile.optional
```

Expected: `ls: cannot access 'lazygit': No such file or directory`, and `11:brew "lazygit"`.

- [ ] **Step 4: Commit**

```bash
git add -A lazygit Brewfile.optional
git commit -m "$(cat <<'EOF'
refactor(lazygit): drop the package

The config held nothing but the Catppuccin theme, and lazygit's
defaults are ANSI, so it follows the terminal's palette unconfigured —
which is what Omarchy does, its own lazygit config being empty. The
tool stays in Brewfile.optional.

Co-Authored-By: Claude Opus 5 <noreply@anthropic.com>
EOF
)"
```

---

### Task 10: Update README.md and CLAUDE.md

**Files:**
- Modify: `README.md` (package table, both `stow` examples, the Omarchy paragraph)
- Modify: `CLAUDE.md` (deployment example, package list, conventions)

**Interfaces:**
- Consumes: the final package set from Tasks 1–9.
- Produces: nothing other tasks depend on.

- [ ] **Step 1: Verify the docs still describe the old world**

```bash
grep -n lazygit README.md CLAUDE.md
```

Expected: several matches in both files — a table row, a stow example, an Omarchy sentence, a package bullet and a conventions bullet.

- [ ] **Step 2: Update the `README.md` package table**

Remove the `lazygit` row. Add a `theme` row after `claude`:

```markdown
| `theme`    | `.config/theme/` (palettes + `current` symlink)  | macOS    |
```

- [ ] **Step 3: Update the `README.md` Omarchy paragraph**

Change "Omarchy ships its own configuration for tmux, ghostty, starship, lazygit, herdr, and Neovim" to drop `lazygit`:

```markdown
The macOS-only rows are not a portability limitation. Omarchy ships its own
configuration for tmux, ghostty, starship, herdr, and Neovim, and re-renders
several of them on `omarchy theme set`; stowing the macOS versions over them
would break theme switching and Omarchy's menus. See "Omarchy" below.
```

Note the phrase "statically themed" is dropped, because after this change they are no longer statically themed.

- [ ] **Step 4: Update both `stow` examples in `README.md`**

```sh
stow git zsh tmux nvim starship theme      # minimal / remote box
stow git zsh tmux nvim ghostty starship \
     jj herdr claude theme macos           # full macOS workstation
```

- [ ] **Step 5: Update the `CLAUDE.md` deployment example**

```sh
stow git zsh tmux nvim starship theme  # install a subset (macOS)
```

- [ ] **Step 6: Update the `CLAUDE.md` package list**

Delete the `lazygit` bullet. Rewrite the `tmux` and `claude` bullets and add a `theme` bullet:

```markdown
- **`tmux`** — `.tmux.conf`; ANSI colours only, so it follows the terminal's palette
- **`claude`** — `.claude/settings.json` and a `themes/theme.json` symlink into the `theme` package
- **`theme`** — `.config/theme/`: one directory per theme plus a tracked `current` symlink; macOS only
```

In the "Everything else is macOS-only" sentence, remove `lazygit` and add `theme`:

```markdown
Everything else is macOS-only. `zsh`, `tmux`, `ghostty`, `starship`, `jj`,
`herdr`, `nvim`, `claude`, and `theme` are **not** stowed on Omarchy — see the
conventions below.
```

- [ ] **Step 7: Replace the theming convention in `CLAUDE.md`**

Replace the bullet beginning "**Catppuccin Mocha** is the consistent theme across tmux, fzf, ghostty, lazygit, jj, and neovim" with:

```markdown
- **The terminal carries the palette.** `theme/` holds one directory per theme
  and a tracked `current` symlink; only tools that cannot read ANSI colours
  (ghostty, neovim, Claude Code) get a file there, and they include it from
  `~/.config/theme/current/`. Everything else uses ANSI colour names and
  inherits the terminal's palette for free. Adding a tool means checking
  whether it reads ANSI before theming it — usually the answer is that it needs
  no theme config at all. On Omarchy the theme is whatever `omarchy theme set`
  selects, and the repo does not fight it.
```

- [ ] **Step 8: Verify the docs match reality**

```bash
grep -c lazygit README.md CLAUDE.md
for p in $(ls -d */ | tr -d /); do grep -q "\`$p\`" README.md || echo "MISSING from README: $p"; done
```

Expected: `README.md:0` and `CLAUDE.md:0`, and no `MISSING` lines. The loop asserts every directory that is now a package appears in the README table; `docs` is the one directory that is not a package, so a `MISSING from README: docs` line is expected and correct.

- [ ] **Step 9: Commit**

```bash
git add README.md CLAUDE.md
git commit -m "$(cat <<'EOF'
docs: describe the theme package and the ANSI convention

Replaces the "Catppuccin everywhere" convention with the rule the
refactor encodes: the terminal carries the palette, and only tools that
cannot read ANSI get a theme file. Drops the lazygit package rows.

Co-Authored-By: Claude Opus 5 <noreply@anthropic.com>
EOF
)"
```

---

### Task 11: Full-repo verification sweep

**Files:**
- Modify: none expected. If this task finds a problem, fix it and commit the fix.

**Interfaces:**
- Consumes: everything from Tasks 1–10.
- Produces: the evidence that the branch is complete.

- [ ] **Step 1: Assert no package outside `theme/` mentions the theme or a hex colour**

```bash
grep -rIn --exclude-dir=.git --exclude-dir=docs --exclude-dir=theme \
  -e 'catppuccin' -e '#[0-9a-fA-F]\{6\}' . ; echo "clean=$?"
```

Expected: `clean=1` (no matches). Any hit other than `README.md` or `CLAUDE.md` prose is a defect — go fix it.

- [ ] **Step 2: Dry-run stow for every macOS package**

```bash
for p in git zsh tmux nvim ghostty starship jj herdr claude theme macos; do
  out=$(stow -n -v "$p" 2>&1 | grep -i 'conflict\|warning')
  [ -n "$out" ] && echo "=== $p ===" && echo "$out"
done
echo "done"
```

Expected: `done` with no `===` sections. Note this runs on Linux, where none of these are deployed, so it checks for internal conflicts only.

- [ ] **Step 3: Re-run every tool parser one final time**

```bash
ghostty +validate-config --config-file=ghostty/.config/ghostty/config; echo "ghostty=$?"
ghostty +validate-config --config-file=theme/.config/theme/catppuccin/ghostty.conf; echo "palette=$?"
tmux -f tmux/.tmux.conf -L sweep new-session -d && tmux -L sweep kill-server; echo "tmux=$?"
STARSHIP_CONFIG=starship/.config/starship.toml starship prompt >/dev/null; echo "starship=$?"
zsh -n zsh/.fzf.zsh && zsh -n zsh/.zshrc; echo "zsh=$?"
python3 -c "import tomllib;[tomllib.load(open(f,'rb')) for f in ['jj/.config/jj/config.toml','herdr/.config/herdr/config.toml','theme/.config/theme/catppuccin/colors.toml']]"; echo "toml=$?"
python3 -c "import json;[json.load(open(f)) for f in ['claude/.claude/settings.json','claude/.claude/themes/theme.json']]"; echo "json=$?"
nvim --headless -c "lua assert(type(dofile('nvim/.config/nvim/lua/plugins/theme.lua'))=='table')" -c qa; echo "nvim=$?"
```

Expected: every echoed value is `0`.

- [ ] **Step 4: Confirm the theme indirection is the only path to colour**

```bash
ls -l theme/.config/theme/current
grep -rn 'config/theme/current' --exclude-dir=.git --exclude-dir=docs .
```

Expected: `current -> catppuccin`, and exactly three references — one each in `ghostty/.config/ghostty/config`, `nvim/.config/nvim/lua/plugins/theme.lua`, and (as a symlink target) `claude/.claude/themes/theme.json`.

- [ ] **Step 5: Review the branch as a whole**

```bash
git log --oneline main..HEAD
git diff --stat main..HEAD
```

Expected: twelve commits (the spec, this plan, and Tasks 1–10), and a diffstat showing roughly 250 deleted lines across `jj`, `lazygit`, `zsh`, `starship`, `tmux` and `claude`, against the new `theme` package.

- [ ] **Step 6: Report what still needs a Mac**

These cannot be verified on Linux and must be checked after `stow theme` on the Mac. List them in the final report rather than attempting them:

- `jj config list` parses and `jj log` renders in terminal colours
- Ghostty picks up the palette include and the window redraws in Catppuccin
- Claude Code resolves `custom:theme` through the symlink
- lazygit renders readably with no config
- `rm -rf ~/.tmux/plugins/catppuccin` after the tmux change
