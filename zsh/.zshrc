# Allow selecting among multiple completion candidates with Tab or arrow keys.
zstyle ':completion:*' menu select

autoload -Uz compinit
compinit

if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook zsh)"
fi

if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi

# enable vi keybindings
bindkey -v

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
[ -f ~/.kubectl.zsh ] && source ~/.kubectl.zsh
[ -f ~/.zshrc.custom ] && source ~/.zshrc.custom

if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi
