# Cross-Platform Keybinding Alignment Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Give macOS tmux and Herdr the approved Omarchy-inspired binding hierarchy without breaking Polish Option input, macOS text navigation, Ghostty shortcuts, or Omarchy ownership and theming.

**Architecture:** Ghostty is the macOS input-transport layer, emitting unambiguous terminal sequences only for approved Option chords. The tracked macOS tmux and Herdr configs consume those chords independently while retaining their existing macOS themes; Omarchy's active configs remain untouched and distribution-owned.

**Tech Stack:** Ghostty configuration, tmux 3.7-compatible configuration, Herdr TOML configuration, GNU Stow package layout, Markdown documentation, shell-based configuration validation.

**Spec:** `docs/superpowers/specs/2026-09-22-cross-platform-keybindings-design.md`

## Global Constraints

- Do not modify any file under `omarchy/`, `~/.config/` on the Linux host, or `/usr/share/omarchy/`.
- Keep macOS Catppuccin theming, TPM, tmux-resurrect, tmux-continuum, and Herdr system notifications intact.
- Set `macos-option-as-alt = false`; never use `true`, `left`, or `right`.
- Do not add Option-letter, Option-arrow, or Command-based multiplexer bindings.
- Keep `Ctrl+Space` as the primary prefix and tmux `Ctrl+B` as its secondary prefix.
- Keep the explicit `x` / `k` / `Shift+k` close hierarchy for pane, window/tab, and session/workspace.
- Give every Option-based direct binding a prefix fallback.
- Treat Option-1 through Option-9 as an isolated experiment removable without affecting any other binding.
- Neovim, zsh, fzf, macOS defaults, and the macOS keyboard-remapping script remain unchanged.

## Review Focus

- Polish Option-letter input: no new Ghostty, tmux, or Herdr binding may claim an Option-letter chord; Task 1 and Task 4 assert this and the macOS checklist exercises it.
- Native Option-arrow editing: no tmux or Herdr root binding may claim Option-arrows or Option-Shift-arrows; Tasks 2–4 assert their absence and the macOS checklist exercises word movement and selection.
- Split-direction identity: Option-Enter must mean stacked panes and Option-Shift-Enter side-by-side panes in both tools; Tasks 1–4 validate the distinct encodings and actions.
- Native Ghostty Command shortcuts: no new `super`/`cmd` binding may enter the tracked Ghostty file; Tasks 1 and 4 assert this, and Task 4 preserves a manual smoke test.
- Close scope: `x` closes a pane, `k` closes a window/tab, and `Shift+k` closes a session/workspace; Tasks 2 and 3 assert all three independently.

---

### Task 1: Add the macOS Ghostty transport bindings

**Files:**
- Modify: `ghostty/.config/ghostty/config:1-2`

**Interfaces:**
- Consumes: macOS Option key events under the Polish keyboard layout.
- Produces: CSI-u `13;3u` for Option-Enter, CSI-u `13;4u` for Option-Shift-Enter, two ESC bytes for Option-Escape, and ESC-prefixed digits for physical Option-1 through Option-9.

- [ ] **Step 1: Demonstrate that the transport contract is absent**

Run:

```bash
test "$(rg -c '^keybind = alt\+(enter|shift\+enter|escape|digit_[1-9])=' ghostty/.config/ghostty/config || true)" -eq 12
```

Expected: exit 1 because the current file contains no keybindings.

- [ ] **Step 2: Add the explicit native-Option policy and narrow encodings**

Append this content after the existing theme line:

```ini

# Preserve Option+letter for Polish characters and native macOS text input.
macos-option-as-alt = false

# Multiplexer pane controls. Modified Enter needs CSI-u so Shift remains distinct.
keybind = alt+enter=csi:13;3u
keybind = alt+shift+enter=csi:13;4u
keybind = alt+escape=text:\x1b\x1b

# Experimental direct window/tab selection. Use physical digit keys so the
# active keyboard layout cannot change which keys trigger these bindings.
keybind = alt+digit_1=text:\x1b1
keybind = alt+digit_2=text:\x1b2
keybind = alt+digit_3=text:\x1b3
keybind = alt+digit_4=text:\x1b4
keybind = alt+digit_5=text:\x1b5
keybind = alt+digit_6=text:\x1b6
keybind = alt+digit_7=text:\x1b7
keybind = alt+digit_8=text:\x1b8
keybind = alt+digit_9=text:\x1b9
```

- [ ] **Step 3: Validate Ghostty syntax**

Run:

```bash
ghostty +validate-config --config-file=ghostty/.config/ghostty/config
```

Expected: exit 0 with no diagnostics.

- [ ] **Step 4: Pin the exact transport surface and forbidden namespaces**

Run:

```bash
test "$(rg -c '^keybind = alt\+(enter|shift\+enter|escape|digit_[1-9])=' ghostty/.config/ghostty/config)" -eq 12
rg -q '^macos-option-as-alt = false$' ghostty/.config/ghostty/config
test "$(rg -c '^keybind = alt\+(enter|shift\+enter|escape|digit_[1-9])=' ghostty/.config/ghostty/config)" -eq "$(rg -c '^keybind = ' ghostty/.config/ghostty/config)"
! rg -n '^keybind = alt\+(left|right|up|down|shift\+(left|right|up|down))=' ghostty/.config/ghostty/config
! rg -n '^keybind = .*(super|cmd|command)\+' ghostty/.config/ghostty/config
```

Expected: all commands exit 0. The third assertion proves that the file contains no additional keybinding outside the twelve approved triggers, thereby excluding Option-letter overrides; the final two assertions explicitly protect Option-arrows and Ghostty's Command namespace.

- [ ] **Step 5: Review the focused diff**

Run:

```bash
git diff --check
git diff -- ghostty/.config/ghostty/config
```

Expected: no whitespace errors; the font and Catppuccin theme lines are unchanged and only the approved transport block is added.

- [ ] **Step 6: Commit the Ghostty transport**

```bash
git add ghostty/.config/ghostty/config
git commit -m "feat(ghostty): encode macOS multiplexer shortcuts"
```

### Task 2: Replace the macOS tmux binding model

**Files:**
- Modify: `tmux/.tmux.conf:32-65`

**Interfaces:**
- Consumes: the Option sequences produced by Task 1 and native Control-Option arrow encodings from Ghostty.
- Produces: the approved pane/window/session action hierarchy, with named bindings usable by the local help popup.

- [ ] **Step 1: Demonstrate that the Omarchy-style direct controls are absent**

Run:

```bash
rg -q '^bind -N "Split pane top/bottom" -n M-Enter ' tmux/.tmux.conf
```

Expected: exit 1 because the current macOS config has only prefix `|` and `-` splits.

- [ ] **Step 2: Replace the terminal-input and binding section**

Keep lines 1–30, including all theme and plugin settings. Replace the current terminal-input, prefix, pane, copy-mode, and split section with the following block, leaving the final TPM `run` line at the bottom of the file:

```tmux
# Terminal input protocol
# https://code.claude.com/docs/en/terminal-config
set -g allow-passthrough on
set -g extended-keys on
set -g extended-keys-format csi-u
set -as terminal-features 'xterm*:extkeys'

# Prefix
set -g prefix C-Space
set -g prefix2 C-b
bind -N "Send prefix" C-Space send-prefix
bind -N "Send secondary prefix" C-b send-prefix -2

# Config, help, and copy mode
bind -N "Reload configuration" q source-file ~/.tmux.conf \; display-message "Configuration reloaded"
bind -N "Show tmux keybindings" ? display-popup -E -w 80% -h 70% -T "Tmux keybindings" "tmux list-keys -N | less -R"
bind -N "Detach" d detach-client
bind -N "Copy mode" '[' copy-mode
setw -g mode-keys vi
bind -N "Begin selection" -T copy-mode-vi v send -X begin-selection
bind -N "Copy selection" -T copy-mode-vi y send -X copy-selection-and-cancel

# Panes
bind -N "Split pane top/bottom" -n M-Enter split-window -v -c "#{pane_current_path}"
bind -N "Split pane side-by-side" -n M-S-Enter split-window -h -c "#{pane_current_path}"
bind -N "Close pane" -n M-Escape kill-pane
bind -N "Split pane top/bottom" h split-window -v -c "#{pane_current_path}"
bind -N "Split pane side-by-side" v split-window -h -c "#{pane_current_path}"
bind -N "Close pane" x kill-pane
bind -N "Zoom pane" z resize-pane -Z
bind -N "Last pane" ';' last-pane

bind -N "Focus pane left" -n C-M-Left select-pane -L
bind -N "Focus pane down" -n C-M-Down select-pane -D
bind -N "Focus pane up" -n C-M-Up select-pane -U
bind -N "Focus pane right" -n C-M-Right select-pane -R

bind -N "Resize pane left" -n C-M-S-Left resize-pane -L 5
bind -N "Resize pane down" -n C-M-S-Down resize-pane -D 5
bind -N "Resize pane up" -n C-M-S-Up resize-pane -U 5
bind -N "Resize pane right" -n C-M-S-Right resize-pane -R 5

# Windows
bind -N "Create window" c new-window -c "#{pane_current_path}"
bind -N "Rename window" r command-prompt -I "#W" "rename-window -- '%%'"
bind -N "Close window" k kill-window
bind -N "Previous window" p select-window -t -1
bind -N "Next window" n select-window -t +1
bind -N "Move window previous" C-p swap-window -t -1 \; select-window -t -1
bind -N "Move window next" C-n swap-window -t +1 \; select-window -t +1

bind -N "Select window 1" 1 select-window -t 1
bind -N "Select window 2" 2 select-window -t 2
bind -N "Select window 3" 3 select-window -t 3
bind -N "Select window 4" 4 select-window -t 4
bind -N "Select window 5" 5 select-window -t 5
bind -N "Select window 6" 6 select-window -t 6
bind -N "Select window 7" 7 select-window -t 7
bind -N "Select window 8" 8 select-window -t 8
bind -N "Select window 9" 9 select-window -t 9

bind -N "Select window 1" -n M-1 select-window -t 1
bind -N "Select window 2" -n M-2 select-window -t 2
bind -N "Select window 3" -n M-3 select-window -t 3
bind -N "Select window 4" -n M-4 select-window -t 4
bind -N "Select window 5" -n M-5 select-window -t 5
bind -N "Select window 6" -n M-6 select-window -t 6
bind -N "Select window 7" -n M-7 select-window -t 7
bind -N "Select window 8" -n M-8 select-window -t 8
bind -N "Select window 9" -n M-9 select-window -t 9

# Sessions
bind -N "Create session" C new-session -c "#{pane_current_path}"
bind -N "Rename session" R command-prompt -I "#S" "rename-session -- '%%'"
bind -N "Close session" K kill-session
bind -N "Previous session" P switch-client -p
bind -N "Next session" N switch-client -n
```

- [ ] **Step 3: Parse the config in an isolated tmux server**

Run:

```bash
tmux -S /tmp/dotfiles-keybindings-tmux.sock -f "$(pwd)/tmux/.tmux.conf" new-session -d -s config-test
tmux -S /tmp/dotfiles-keybindings-tmux.sock list-keys -T root
tmux -S /tmp/dotfiles-keybindings-tmux.sock list-keys -T prefix
tmux -S /tmp/dotfiles-keybindings-tmux.sock kill-server
```

Expected: all commands exit 0. If the sandbox rejects Unix socket creation, rerun these same commands with the required sandbox escalation. The named socket isolates the check from every user tmux server.

- [ ] **Step 4: Assert direction, fallback, and close-scope bindings**

Run against a fresh isolated server:

```bash
tmux -S /tmp/dotfiles-keybindings-tmux.sock -f "$(pwd)/tmux/.tmux.conf" new-session -d -s config-test
tmux -S /tmp/dotfiles-keybindings-tmux.sock list-keys -T root | rg 'M-Enter.*split-window -v'
tmux -S /tmp/dotfiles-keybindings-tmux.sock list-keys -T root | rg 'M-S-Enter.*split-window -h'
tmux -S /tmp/dotfiles-keybindings-tmux.sock list-keys -T root | rg 'M-Escape.*kill-pane'
tmux -S /tmp/dotfiles-keybindings-tmux.sock list-keys -T prefix | rg ' h +split-window -v'
tmux -S /tmp/dotfiles-keybindings-tmux.sock list-keys -T prefix | rg ' v +split-window -h'
tmux -S /tmp/dotfiles-keybindings-tmux.sock list-keys -T prefix | rg ' x +kill-pane'
tmux -S /tmp/dotfiles-keybindings-tmux.sock list-keys -T prefix | rg ' k +kill-window'
tmux -S /tmp/dotfiles-keybindings-tmux.sock list-keys -T prefix | rg ' K +kill-session'
tmux -S /tmp/dotfiles-keybindings-tmux.sock list-keys -T prefix | rg ' 1 +select-window -t 1'
tmux -S /tmp/dotfiles-keybindings-tmux.sock list-keys -T root | rg 'M-1 +select-window -t 1'
! tmux -S /tmp/dotfiles-keybindings-tmux.sock list-keys -T root | rg 'M-(S-)?(Left|Right|Up|Down)'
tmux -S /tmp/dotfiles-keybindings-tmux.sock kill-server
```

Expected: each positive search prints one binding; the negative search prints nothing and exits successfully through `!`. Plain and Shifted Option-arrows remain unclaimed.

- [ ] **Step 5: Protect the macOS theme and plugin configuration**

Run:

```bash
git diff --check
git diff -- tmux/.tmux.conf
rg -q "^set -g @catppuccin_flavor \"mocha\"$" tmux/.tmux.conf
rg -q "^set -g @continuum-restore 'on'$" tmux/.tmux.conf
test "$(tail -n 1 tmux/.tmux.conf)" = "run '~/.tmux/plugins/tpm/tpm'"
```

Expected: no whitespace errors; the focused diff changes only terminal-input and binding behavior; all three preservation assertions pass.

- [ ] **Step 6: Commit the tmux mapping**

```bash
git add tmux/.tmux.conf
git commit -m "feat(tmux): align macOS bindings with Omarchy"
```

### Task 3: Give macOS Herdr the matching explicit key map

**Files:**
- Modify: `herdr/.config/herdr/config.toml:1-8`

**Interfaces:**
- Consumes: the Option and Control-Option terminal sequences established in Tasks 1 and 2.
- Produces: Herdr workspace/tab/pane actions whose names and chords match the approved tmux hierarchy.

- [ ] **Step 1: Demonstrate that the explicit key map is absent**

Run:

```bash
rg -q '^prefix = "ctrl\+space"$' herdr/.config/herdr/config.toml
```

Expected: exit 1 because the current tracked Herdr file contains only onboarding, theme, and toast settings.

- [ ] **Step 2: Replace the file with the complete explicit macOS configuration**

Use this exact content:

```toml
onboarding = false

[theme]
# Catppuccin Mocha, matching Ghostty, tmux, fzf, and Neovim.
name = "catppuccin"

[terminal]
# Match tmux's -c "#{pane_current_path}" behavior.
new_cwd = "follow"

[keys]
prefix = "ctrl+space"

# Config and help
reload_config = "prefix+q"
help = "prefix+?"
detach = "prefix+d"

# Copy mode
copy_mode = "prefix+["

# Panes
split_horizontal = ["prefix+h", "alt+enter"]
split_vertical = ["prefix+v", "alt+shift+enter"]
close_pane = ["prefix+x", "alt+esc"]
zoom = "prefix+z"
last_pane = "prefix+;"

focus_pane_left = "ctrl+alt+left"
focus_pane_down = "ctrl+alt+down"
focus_pane_up = "ctrl+alt+up"
focus_pane_right = "ctrl+alt+right"

resize_pane_left = "ctrl+alt+shift+left"
resize_pane_down = "ctrl+alt+shift+down"
resize_pane_up = "ctrl+alt+shift+up"
resize_pane_right = "ctrl+alt+shift+right"

# Tabs (tmux windows)
new_tab = "prefix+c"
rename_tab = "prefix+r"
close_tab = "prefix+k"
switch_tab = ["prefix+1..9", "alt+1..9"]
previous_tab = "prefix+p"
next_tab = "prefix+n"
move_tab_previous = "prefix+ctrl+p"
move_tab_next = "prefix+ctrl+n"

# Workspaces (tmux sessions)
new_workspace = "prefix+shift+c"
rename_workspace = "prefix+shift+r"
close_workspace = "prefix+shift+k"
previous_workspace = "prefix+shift+p"
next_workspace = "prefix+shift+n"

[ui.toast]
delivery = "system"
```

Herdr names a stacked split `split_horizontal` and a side-by-side split `split_vertical`; the comments and chord mapping intentionally follow the visible pane topology rather than tmux's `-v`/`-h` flags.

- [ ] **Step 3: Validate Herdr syntax and key uniqueness**

Run:

```bash
HERDR_CONFIG_PATH="$(pwd)/herdr/.config/herdr/config.toml" herdr config check
```

Expected: `config: ok` and exit 0. Any duplicate or invalid binding must be resolved before continuing.

- [ ] **Step 4: Assert the cross-tool hierarchy and protected Option chords**

Run:

```bash
rg -q '^split_horizontal = \["prefix\+h", "alt\+enter"\]$' herdr/.config/herdr/config.toml
rg -q '^split_vertical = \["prefix\+v", "alt\+shift\+enter"\]$' herdr/.config/herdr/config.toml
rg -q '^close_pane = \["prefix\+x", "alt\+esc"\]$' herdr/.config/herdr/config.toml
rg -q '^close_tab = "prefix\+k"$' herdr/.config/herdr/config.toml
rg -q '^close_workspace = "prefix\+shift\+k"$' herdr/.config/herdr/config.toml
rg -q '^switch_tab = \["prefix\+1\.\.9", "alt\+1\.\.9"\]$' herdr/.config/herdr/config.toml
! rg -n ' = .*alt\+(shift\+)?(left|right|up|down)' herdr/.config/herdr/config.toml
```

Expected: all positive assertions pass; the final negative assertion confirms that native macOS Option-arrow behavior remains available.

- [ ] **Step 5: Protect theme and notifications**

Run:

```bash
git diff --check
git diff -- herdr/.config/herdr/config.toml
rg -q '^name = "catppuccin"$' herdr/.config/herdr/config.toml
rg -q '^delivery = "system"$' herdr/.config/herdr/config.toml
```

Expected: no whitespace errors, and both existing macOS presentation settings remain.

- [ ] **Step 6: Commit the Herdr mapping**

```bash
git add herdr/.config/herdr/config.toml
git commit -m "feat(herdr): mirror macOS tmux bindings"
```

### Task 4: Document and verify the complete cross-platform contract

**Files:**
- Modify: `README.md:69`

**Interfaces:**
- Consumes: the final Ghostty, tmux, and Herdr bindings from Tasks 1–3.
- Produces: user-facing deployment semantics, the intentional macOS exceptions, and the manual macOS acceptance checklist.

- [ ] **Step 1: Demonstrate that the README does not yet document the model**

Run:

```bash
rg -q '^### tmux and Herdr keybindings$' README.md
```

Expected: exit 1.

- [ ] **Step 2: Add the keybinding section after the TPM installation note**

Insert this section after “Start tmux and press `prefix + I` to install plugins.”:

```markdown
### tmux and Herdr keybindings

On macOS, tmux sessions map to Herdr workspaces, tmux windows to Herdr tabs,
and panes to panes. Both tools use `Ctrl+Space` as their prefix (`Ctrl+B` is
also a secondary tmux prefix).

| Action | Binding |
| ------ | ------- |
| Split top/bottom | `Option+Enter` or `prefix+h` |
| Split side-by-side | `Option+Shift+Enter` or `prefix+v` |
| Close pane | `Option+Escape` or `prefix+x` |
| Focus pane | `Ctrl+Option+arrows` |
| Resize pane | `Ctrl+Option+Shift+arrows` |
| Create / rename / close window or tab | `prefix+c` / `prefix+r` / `prefix+k` |
| Previous / next window or tab | `prefix+p` / `prefix+n` |
| Create / rename / close session or workspace | `prefix+Shift+c/r/k` |
| Previous / next session or workspace | `prefix+Shift+p/n` |

`prefix+1..9` always selects a window or tab. `Option+1..9` is also enabled as
an experiment; remove its Ghostty, tmux, and Herdr entries together if it
interferes with symbol input.

macOS deliberately keeps every Option-arrow chord for native word movement and
selection, so it does not copy Omarchy's direct Alt-arrow navigation. Ghostty
also keeps Option in native macOS mode, preserving Option-letter Polish
characters. Omarchy continues to own its Linux configs and dynamic theming; do
not stow the macOS `tmux`, `herdr`, or `ghostty` packages there.
```

- [ ] **Step 3: Run all static validators**

Run:

```bash
ghostty +validate-config --config-file=ghostty/.config/ghostty/config
HERDR_CONFIG_PATH="$(pwd)/herdr/.config/herdr/config.toml" herdr config check
tmux -S /tmp/dotfiles-keybindings-tmux.sock -f "$(pwd)/tmux/.tmux.conf" new-session -d -s config-test
tmux -S /tmp/dotfiles-keybindings-tmux.sock list-keys -N
tmux -S /tmp/dotfiles-keybindings-tmux.sock kill-server
git diff --check
```

Expected: Ghostty exits 0 without diagnostics; Herdr prints `config: ok`; tmux loads and lists named bindings; `git diff --check` is silent. Use sandbox escalation only for the isolated tmux socket if required.

- [ ] **Step 4: Assert cross-file agreement and scope**

Run:

```bash
rg -q '^keybind = alt\+enter=csi:13;3u$' ghostty/.config/ghostty/config
rg -q '^bind -N "Split pane top/bottom" -n M-Enter ' tmux/.tmux.conf
rg -q '^split_horizontal = \["prefix\+h", "alt\+enter"\]$' herdr/.config/herdr/config.toml
rg -q '^keybind = alt\+shift\+enter=csi:13;4u$' ghostty/.config/ghostty/config
rg -q '^bind -N "Split pane side-by-side" -n M-S-Enter ' tmux/.tmux.conf
rg -q '^split_vertical = \["prefix\+v", "alt\+shift\+enter"\]$' herdr/.config/herdr/config.toml
rg -q '^keybind = alt\+escape=text:\\x1b\\x1b$' ghostty/.config/ghostty/config
rg -q '^bind -N "Close pane" -n M-Escape kill-pane$' tmux/.tmux.conf
rg -q '^close_pane = \["prefix\+x", "alt\+esc"\]$' herdr/.config/herdr/config.toml
test "$(rg -c '^keybind = alt\+(enter|shift\+enter|escape|digit_[1-9])=' ghostty/.config/ghostty/config)" -eq "$(rg -c '^keybind = ' ghostty/.config/ghostty/config)"
! rg -n '^keybind = alt\+(left|right|up|down|shift\+(left|right|up|down))=' ghostty/.config/ghostty/config
! rg -n '^keybind = .*(super|cmd|command)\+' ghostty/.config/ghostty/config
! rg -n ' -n M-[[:alpha:]]( |$)' tmux/.tmux.conf
! rg -n 'alt\+[[:alpha:]]("|,|\])' herdr/.config/herdr/config.toml
! rg -n ' -n M-(S-)?(Left|Right|Up|Down) ' tmux/.tmux.conf
! rg -n ' = .*alt\+(shift\+)?(left|right|up|down)' herdr/.config/herdr/config.toml
test -z "$(git diff --name-only main...HEAD -- omarchy nvim zsh macos)"
test -z "$(git diff --name-only -- omarchy nvim zsh macos)"
```

Expected: every assertion passes and the final two commands confirm that no excluded package changed in either committed or uncommitted implementation work.

- [ ] **Step 5: Record the macOS acceptance run in the handoff**

On the macOS machine after pulling and stowing the branch, perform this exact checklist; do not claim it passed from Linux:

```text
[ ] Lowercase Polish Option letters type correctly in a plain Ghostty shell.
[ ] Uppercase Polish Option letters type correctly in a plain Ghostty shell.
[ ] Option-Left/Right moves by word.
[ ] Option-Shift-Left/Right selects by word.
[ ] Command-based Ghostty copy/paste, tabs, splits, search, and windows still work.
[ ] tmux direct and prefix split/close bindings produce the intended topology.
[ ] tmux pane focus/resize, window actions, and session actions work.
[ ] Herdr pane focus/resize, tab actions, and workspace actions work.
[ ] Option-1..9 is acceptable for daily use; otherwise remove the experiment as a unit.
[ ] macOS Spaces shortcuts are unchanged.
[ ] ghostty +list-keybinds shows the intended custom transport bindings.
```

Expected: include this checklist in the final handoff with Linux-verifiable items marked complete and macOS-only items explicitly left for the user unless they have actually been run on macOS.

- [ ] **Step 6: Review the complete branch diff**

Run:

```bash
git status --short
git diff -- README.md
git diff --stat main...HEAD
git diff main...HEAD -- ghostty/.config/ghostty/config tmux/.tmux.conf herdr/.config/herdr/config.toml docs/superpowers/specs/2026-09-22-cross-platform-keybindings-design.md docs/superpowers/plans/2026-09-22-cross-platform-keybindings.md
```

Expected: only `README.md` is uncommitted at this point and its focused diff contains only the new documentation. The committed branch diff contains the spec, plan, and three macOS config changes, with no Omarchy theme or Linux configuration changes. The final commit and Step 8 add `README.md` to the complete branch diff.

- [ ] **Step 7: Commit the documentation**

```bash
git add README.md
git commit -m "docs: explain cross-platform keybindings"
```

- [ ] **Step 8: Run the final repository checks**

Run:

```bash
git diff --check main...HEAD
git status --short
git log --oneline main..HEAD
```

Expected: no whitespace errors, a clean working tree, and separate commits for the approved spec, implementation plan, Ghostty transport, tmux bindings, Herdr bindings, and README documentation.
