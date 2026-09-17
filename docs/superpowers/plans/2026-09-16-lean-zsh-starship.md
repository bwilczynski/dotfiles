# Lean Zsh and Starship Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace Oh My Zsh and Powerlevel10k with direct Zsh initialization and a minimal Catppuccin Mocha Starship prompt, while removing unused autojump and devbox configuration.

**Architecture:** `.zshrc` becomes a small, ordered native Zsh startup file: completion and direnv first, current shell settings and optional modules next, then guarded Starship initialization. `.config/starship.toml` owns all prompt rendering. The legacy P10k and devbox files are removed, and README documents the single required prompt package.

**Tech Stack:** Zsh 5.9, Homebrew, Starship TOML configuration, GNU Stow.

**Spec:** `docs/superpowers/specs/2026-09-16-lean-zsh-starship-design.md`

## Global Constraints

- Preserve vi keybindings, locale settings, SSH-aware editor selection, fzf, kubectl, and optional private `.zshrc.custom` sourcing.
- Do not replace OMZ Git aliases or its gitignore helper.
- Do not delete external `~/.oh-my-zsh` or Powerlevel10k installation directories.
- Starship must be optional at shell startup if its executable is unavailable.
- Use Catppuccin Mocha colors already used in `.fzf.zsh`.
- Display command duration only after five seconds; display username and hostname only on SSH connections.

---

### Task 1: Replace framework-based Zsh startup

**Files:**
- Modify: `.zshrc`
- Delete: `.devbox.zsh`
- Delete: `.p10k.zsh`

**Interfaces:**
- Consumes: Homebrew-provided `direnv`, existing `.fzf.zsh`, `.kubectl.zsh`, and an optional private `~/.zshrc.custom`.
- Produces: A framework-free Zsh startup file that initializes Starship only when `starship` is on `PATH`.

- [ ] **Step 1: Establish the legacy references that must disappear**

Run:

```sh
rg -n 'oh-my-zsh|powerlevel10k|p10k|autojump|devbox' .zshrc .p10k.zsh .devbox.zsh
```

Expected: `.zshrc` contains Oh My Zsh, Powerlevel10k, autojump-plugin, and devbox references; legacy files exist.

- [ ] **Step 2: Rewrite `.zshrc` with direct initialization**

Replace framework setup with this ordered behavior:

```zsh
autoload -Uz compinit
compinit

if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook zsh)"
fi

# Existing editor, vi mode, locale, and optional fzf/kubectl/custom sourcing remain.

if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi
```

Do not source `.devbox.zsh`; do not initialize autojump, Oh My Zsh, P10k instant prompt, or `.p10k.zsh`.

- [ ] **Step 3: Delete the repository-owned legacy configuration**

Run:

```sh
git rm .p10k.zsh .devbox.zsh
```

Expected: both files are staged as deleted; no path outside the repository is affected.

- [ ] **Step 4: Verify Zsh syntax and legacy removal**

Run:

```sh
zsh -n .zshrc
! rg -n 'oh-my-zsh|powerlevel10k|p10k|autojump|devbox' .zshrc
```

Expected: `zsh -n` exits 0 and the negative search exits 0.

- [ ] **Step 5: Commit the framework removal**

```sh
git add .zshrc .p10k.zsh .devbox.zsh
git commit -m "refactor: replace omz with native zsh setup"
```

### Task 2: Add the minimal Starship prompt

**Files:**
- Create: `.config/starship.toml`

**Interfaces:**
- Consumes: Starship’s Zsh initialization from `.zshrc` and the terminal’s Catppuccin Mocha palette.
- Produces: A two-line prompt: directory/Git on the information line, command duration/Python virtualenv/SSH context right-aligned, and a vi-aware prompt character on the input line.

- [ ] **Step 1: Create the Starship configuration**

Create `.config/starship.toml` with this complete minimal configuration:

```toml
"$schema" = 'https://starship.rs/config-schema.json'
add_newline = false
scan_timeout = 10
command_timeout = 500
palette = 'catppuccin_mocha'
format = '$directory$git_branch$git_status$fill$cmd_duration$python$username$hostname$line_break$character'

[palettes.catppuccin_mocha]
blue = '#89b4fa'
grey = '#a6adc8'
yellow = '#f9e2af'
magenta = '#cba6f7'
red = '#f38ba8'
white = '#cdd6f4'

[directory]
style = 'blue'
truncation_length = 0
truncate_to_repo = false
format = '[$path]($style) '

[git_branch]
symbol = ''
style = 'grey'
format = '[$branch]($style) '

[git_status]
style = 'grey'
format = '([$all_status$ahead_behind]($style) )'
conflicted = '='
ahead = '⇡${count}'
behind = '⇣${count}'
diverged = '⇕⇡${ahead_count}⇣${behind_count}'
untracked = '*'
stashed = '≡'
modified = '!'
staged = '+'
renamed = '»'
deleted = '✘'

[cmd_duration]
min_time = 5_000
style = 'yellow'
format = '[$duration]($style) '

[python]
style = 'grey'
format = '[($virtualenv )]($style)'

[username]
show_always = false
style_user = 'grey'
format = '[$user]($style)'

[hostname]
ssh_only = true
style = 'grey'
format = '[@$hostname]($style) '

[character]
success_symbol = '[❯](magenta)'
error_symbol = '[❯](red)'
vimcmd_symbol = '[❮](magenta)'
```

The custom `format` is the only module list, so language, package, cloud, time, and decorative-icon modules remain absent.

- [ ] **Step 2: Install Starship through Homebrew**

Run:

```sh
brew install starship
```

Expected: `command -v starship` resolves to a Homebrew path and `starship --version` succeeds.

- [ ] **Step 3: Validate the Starship configuration**

Run:

```sh
STARSHIP_CONFIG="$PWD/.config/starship.toml" starship prompt
```

Expected: the command exits 0 and renders a prompt without configuration errors.

- [ ] **Step 4: Verify direct shell startup with the repository configuration**

Run:

```sh
XDG_CONFIG_HOME="$PWD/.config" ZDOTDIR="$PWD" zsh -ic 'command -v starship; print -r -- "${STARSHIP_SHELL:-missing}"'
```

Expected: `starship` is found and `STARSHIP_SHELL` is `zsh`; unrelated personal shell files are not read.

- [ ] **Step 5: Commit the prompt configuration**

```sh
git add .config/starship.toml
git commit -m "feat: add minimal starship prompt"
```

### Task 3: Document the prerequisite and finish verification

**Files:**
- Modify: `README.md`

**Interfaces:**
- Consumes: Starship installed through Homebrew and the Stow deployment model described in README.
- Produces: A concise prerequisite and deployment note that makes a fresh-machine setup reproducible.

- [ ] **Step 1: Add a shell prerequisite section to README**

Add the following concise installation instruction near the deployment guidance:

```sh
brew install starship direnv fzf kubectl kustomize
```

State that the repository provides `~/.config/starship.toml` through Stow and that Starship is initialized by `.zshrc` when installed.

- [ ] **Step 2: Validate repository consistency**

Run:

```sh
zsh -n .zshrc
STARSHIP_CONFIG="$PWD/.config/starship.toml" starship prompt
git diff --check HEAD
git status --short
```

Expected: syntax and config checks exit 0, `git diff --check` reports no whitespace errors, and only `README.md` is pending before its commit.

- [ ] **Step 3: Commit documentation**

```sh
git add README.md
git commit -m "docs: document shell prompt prerequisite"
```

- [ ] **Step 4: Run final acceptance checks**

Run:

```sh
git status --short
git log --oneline -3
zsh -n .zshrc
STARSHIP_CONFIG="$PWD/.config/starship.toml" starship prompt
```

Expected: clean worktree, three migration commits, valid Zsh syntax, and a successfully rendered Starship prompt.
