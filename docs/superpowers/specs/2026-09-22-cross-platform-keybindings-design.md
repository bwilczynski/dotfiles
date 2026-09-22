# Cross-Platform Keybinding Alignment Design

## Goal

Align the day-to-day tmux and Herdr keybindings on macOS with Omarchy's
interaction model while preserving native macOS text editing, Polish character
entry, Ghostty shortcuts, and all Omarchy-managed theming and configuration.

Success means that pane, window/tab, and session/workspace operations use the
same hierarchy on both platforms, with documented macOS translations wherever
a literal Omarchy chord conflicts with native behavior.

## Scope

- Update the tracked macOS tmux configuration with the selected binding model.
- Give the tracked macOS Herdr configuration an explicit matching key map.
- Add narrowly scoped Ghostty encodings for macOS Option chords that must reach
  terminal applications distinctly.
- Document the cross-platform binding model and its intentional differences.
- Validate the configuration statically on Linux and interactively on macOS.

Neovim is excluded from implementation because both installations already use
LazyVim's default keymaps and neither defines personal overrides in
`lua/config/keymaps.lua`. The macOS-only Xcodebuild mappings are feature-specific
rather than a competing navigation model.

Zsh, fzf, macOS workspace shortcuts, and the macOS keyboard remapping script
also remain unchanged. The selected bindings avoid their useful shortcuts.

## Ownership Model

Omarchy remains the reference for the interaction hierarchy, but its files are
not shared, replaced, or tracked by this repository. Omarchy continues to own
its tmux, Herdr, Ghostty, and Neovim configuration, including migrations,
keybinding-menu integration, and dynamic theme rendering.

The macOS packages implement the same semantics in their existing platform-
owned files:

- `tmux/.tmux.conf` retains TPM, tmux-resurrect, tmux-continuum, and the static
  Catppuccin status line. Only bindings and required input-protocol settings
  change.
- `herdr/.config/herdr/config.toml` retains the Catppuccin theme and system
  notification delivery. It gains explicit terminal, key, and minimal behavior
  settings needed to mirror tmux.
- `ghostty/.config/ghostty/config` retains its font and Catppuccin theme. It
  gains only the macOS Option policy and specific key encodings required by the
  selected direct bindings.

There is no generated common keymap. The small amount of duplication is
deliberate: it avoids taking ownership of Omarchy files and keeps each tool's
configuration directly readable.

## Interaction Model

The hierarchy maps equivalent containers across the two multiplexers:

| tmux | Herdr |
| --- | --- |
| session | workspace |
| window | tab |
| pane | pane |

Lowercase prefix commands operate on windows/tabs. The corresponding uppercase
commands operate on sessions/workspaces. Pane operations use `x` for close and
spatial chords for split, focus, and resize.

### Binding Contract

| Scope | Action | macOS binding |
| --- | --- | --- |
| General | Prefix | `Ctrl+Space`; tmux also retains `Ctrl+B` as a secondary prefix |
| General | Reload configuration | `prefix+q` |
| General | Show binding help | `prefix+?` |
| General | Detach | `prefix+d` |
| Copy | Enter copy mode | `prefix+[` |
| Pane | Split into top and bottom panes | `Option+Enter` or `prefix+h` |
| Pane | Split into side-by-side panes | `Option+Shift+Enter` or `prefix+v` |
| Pane | Close focused pane | `Option+Escape` or `prefix+x` |
| Pane | Toggle zoom | `prefix+z` |
| Pane | Focus previously focused pane | `prefix+;` |
| Pane | Focus by direction | `Ctrl+Option+arrows` |
| Pane | Resize by direction | `Ctrl+Option+Shift+arrows` |
| Window/tab | Create | `prefix+c` |
| Window/tab | Rename | `prefix+r` |
| Window/tab | Close | `prefix+k` |
| Window/tab | Select 1 through 9 | `prefix+1..9`; trial `Option+1..9` |
| Window/tab | Previous or next | `prefix+p` / `prefix+n` |
| Window/tab | Move previous or next | `prefix+Ctrl+p` / `prefix+Ctrl+n` |
| Session/workspace | Create | `prefix+Shift+c` |
| Session/workspace | Rename | `prefix+Shift+r` |
| Session/workspace | Close | `prefix+Shift+k` |
| Session/workspace | Previous or next | `prefix+Shift+p` / `prefix+Shift+n` |

The close hierarchy is intentionally explicit:

- `x` closes a pane.
- `k` closes a window/tab.
- `Shift+k` closes a session/workspace.

In tmux, killing the final pane also destroys its containing window as a tmux
side effect. Users should still use `prefix+k` when the intent is explicitly to
close a window or tab; the design does not rely on equivalent cascading behavior
from Herdr.

### Intentional macOS Translations

Omarchy uses direct `Alt+Left/Right` for window navigation,
`Alt+Shift+Left/Right` for window movement, and `Alt+Up/Down` for session
navigation. Those chords are not copied to macOS:

- `Option+Left/Right` retains word navigation.
- `Option+Shift+Left/Right` retains word selection.
- `Option+Up/Down` remains available to native text and application behavior.

The prefix alternatives in the binding contract provide the corresponding
multiplexer actions. No new Command-based bindings are introduced, leaving
macOS and Ghostty's native window, tab, split, copy, paste, search, and
application shortcuts intact.

`Ctrl+Space` remains the prefix because it is already used successfully on the
macOS machine. `Ctrl+Option` is available for pane navigation because VoiceOver
is not used and is not planned for this setup. If that accessibility requirement
changes, pane focus and resize bindings must be reconsidered because
Control-Option is VoiceOver's default modifier.

## Ghostty Input Transport

Ghostty must preserve Option as the macOS character-composition modifier. The
configuration therefore sets `macos-option-as-alt = false`; it must not set the
option to `true`, `left`, or `right`.

Specific keybindings encode only the selected direct multiplexer chords:

- Option-Enter and Option-Shift-Enter produce distinct CSI-u sequences so tmux
  and Herdr can distinguish the two split directions.
- Option-Escape produces CSI-u `27;3u`, the encoding expected by the direct
  close binding.
- Physical Option-1 through Option-9 produce terminal Alt-number sequences for
  the trial direct window/tab selectors.

Using physical digit triggers makes the experiment independent of the Unicode
character produced by the active Polish keyboard layout. It intentionally
claims only those nine combinations. Option-letter and Option-arrow handling is
not overridden.

Tmux enables extended keys with CSI-u format so modified Enter and arrow events
remain distinct. Herdr consumes the same terminal encodings through its own key
configuration.

## Tool-Specific Behavior

### tmux

The existing macOS appearance, plugins, automatic restore, copy-mode bindings,
and terminal capability settings remain. The binding block is expanded to
implement the contract with descriptive `-N` labels where supported.

The help binding must be macOS-local. It displays tmux's described effective
bindings and must not call `omarchy-menu-tmux-keybindings`, which is unavailable
on macOS.

Splits, new windows, and new sessions start in the current pane's working
directory, matching Omarchy.

### Herdr

Herdr uses `Ctrl+Space` as its prefix and explicitly maps its workspace, tab,
and pane actions to the contract. Its theme remains Catppuccin and toast
delivery remains `system`.

`terminal.new_cwd = "follow"` ensures new panes, tabs, and workspaces inherit
the source location, matching tmux's `-c "#{pane_current_path}"` behavior.

The built-in Herdr help view remains bound to `prefix+?`. The design does not
alter Herdr's theme or attempt to reproduce Omarchy's terminal-palette theme on
macOS.

### Ghostty

Ghostty is an input transport layer for these bindings, not another owner of
multiplexer behavior. Its native Command-based tabs and splits remain
available. No bindings are added for Option letters or arrows.

### Neovim and Shell

Neovim receives no changes. The chosen direct pane-focus and resize chords do
not overlap the tracked or installed LazyVim mappings.

Zsh remains in vi mode. The design preserves Option-arrow word movement and
does not claim Option-letter chords used for Polish characters or fzf shell
bindings.

## Experimental Option-Number Bindings

Direct Option-1 through Option-9 selection is intentionally experimental.
Prefix-1 through prefix-9 is the guaranteed binding on both tmux and Herdr.

The Option-number bindings ship in the first implementation so they can be
tested during ordinary macOS use. If any of them are useful for symbol entry or
behave inconsistently with the Polish layout, remove both sides of the feature:

1. Remove the Option-number encodings from Ghostty.
2. Remove the direct Alt-number selectors from tmux and Herdr.

No other binding depends on the experiment.

## Documentation

`README.md` will gain a concise keybinding section that:

- Describes the session/workspace, window/tab, and pane mapping.
- Lists the primary direct and prefix bindings.
- Explains why macOS deliberately omits Omarchy's direct Alt-arrow bindings.
- Notes that Option-number selection is provisional.
- States that Omarchy's configuration remains distribution-owned and
  theme-dynamic.

Repository guidance should continue to describe the macOS packages as
macOS-only and must not recommend stowing them over Omarchy.

## Validation

### Static validation

- Parse the tracked tmux configuration in an isolated tmux server and inspect
  its effective bindings and descriptions.
- Run `herdr config check` with `HERDR_CONFIG_PATH` pointing at the tracked
  macOS Herdr file.
- Parse the tracked Ghostty configuration and inspect the effective bindings.
- Confirm that the diff contains no Omarchy package files or Linux user
  configuration.
- Review the final diff for accidental theme, plugin, or unrelated option
  changes.

Static checks on Linux cannot prove macOS keyboard-layout behavior, so they are
necessary but not sufficient.

### Interactive macOS validation

1. In a plain Ghostty shell, type all lower- and uppercase Polish characters
   produced with Option.
2. Confirm Option-Left/Right moves by word and Option-Shift-Left/Right selects by
   word.
3. Confirm existing Command-based Ghostty tabs, splits, copy/paste, search, and
   window controls still work.
4. In tmux, test both direct and prefix split bindings, both close-pane
   bindings, directional focus, directional resize, window operations, and
   session operations.
5. In Herdr, repeat the equivalent pane, tab, and workspace operations.
6. Test Option-1 through Option-9 in a plain shell, tmux, and Herdr. Remove the
   experiment as a unit if it interferes with desired character entry.
7. Confirm macOS Spaces shortcuts remain unchanged.
8. Run `ghostty +list-keybinds` on the Mac and confirm that each intended chord
   resolves to the expected transport action.

## Failure Containment and Maintenance

Every Option-based direct binding has a prefix fallback. A layout-specific or
terminal-encoding failure therefore cannot make splitting, closing, or indexed
window/tab selection inaccessible. Pane focus and resize use the dedicated
Control-Option arrow chords whose availability was established during design.

The experimental Option-number feature is isolated and removable. Polish
character entry is protected by the explicit native Option policy and by the
absence of Option-letter overrides. Native word navigation is protected by the
absence of Option-arrow multiplexer bindings.

Future Omarchy updates may evolve its default bindings. They do not modify the
macOS files automatically. Alignment is semantic rather than generated: review
material Omarchy tmux or Herdr changes deliberately and port only those that
fit the macOS conflict rules in this document.
