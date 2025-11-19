if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export ZSH=~/.oh-my-zsh
DEFAULT_USER=bwilczynski
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(autojump colorize gitignore)

source $ZSH/oh-my-zsh.sh

if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi

# enable vi keybindings
bindkey -v

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

[ -f ~/.p10k.zsh ] && source ~/.p10k.zsh
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
[ -f ~/.devbox.zsh ] && source ~/.devbox.zsh
[ -f ~/.kubectl.zsh ] && source ~/.kubectl.zsh
[ -f ~/.zshrc.custom ] && source ~/.zshrc.custom
