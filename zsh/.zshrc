# Allow selecting among multiple completion candidates with Tab or arrow keys.
zstyle ':completion:*' menu select

autoload -Uz compinit
compinit

# enable vi keybindings. Before fzf, since it resets the keymap and would drop
# fzf's widgets.
bindkey -v

if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate zsh)"
fi

if command -v gh >/dev/null 2>&1; then
  eval "$(gh completion -s zsh)"
fi

if command -v unifictl >/dev/null 2>&1; then
  eval "$(unifictl completions zsh)"
fi

if command -v synoctl >/dev/null 2>&1; then
  eval "$(synoctl completions zsh)"
fi

if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook zsh)"
fi

if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi

# Setup fzf, including shell completion and key bindings.
if command -v fzf >/dev/null 2>&1; then
  source <(fzf --zsh)
fi

# Run yazi and cd to the directory it was in on quit.
if command -v yazi >/dev/null 2>&1; then
  function y() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
    yazi "$@" --cwd-file="$tmp"
    IFS= read -r -d '' cwd < "$tmp"
    [ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
    rm -f -- "$tmp"
  }
fi

[ -f ~/.zshrc.custom ] && source ~/.zshrc.custom

if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi
