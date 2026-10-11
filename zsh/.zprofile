# Login shells only, once per session: environment that every process started
# afterwards inherits. Interactive setup (prompt, completion, hooks) belongs in
# .zshrc. This runs after /etc/zprofile's path_helper, which would otherwise
# reorder anything set earlier in .zshenv.

if [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Scripts stowed from this repo, such as theme-set. Only when not already on
# PATH: Omarchy's /etc/profile appends it after mise's shims, and its
# ~/.local/bin holds install-on-demand wrappers that must not shadow them.
if [ -d "$HOME/.local/bin" ] && [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
  export PATH="$HOME/.local/bin:$PATH"
fi

# Obsidian's CLI, used by the obsidian agent skills.
if [ -d /Applications/Obsidian.app/Contents/MacOS ]; then
  export PATH="$PATH:/Applications/Obsidian.app/Contents/MacOS"
fi
