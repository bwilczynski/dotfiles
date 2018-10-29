#!/bin/bash

OH_MY_ZSH=~/.oh-my-zsh
ZSH_CUSTOM="$OH_MY_ZSH/custom"

if [ ! -d "$OH_MY_ZSH" ]; then
  curl -L https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh | sh
fi

cp ohmyzsh/*.zsh $ZSH_CUSTOM

git clone https://github.com/denysdovhan/spaceship-prompt.git "$ZSH_CUSTOM/themes/spaceship-prompt" \
  && ln -s "$ZSH_CUSTOM/themes/spaceship-prompt/spaceship.zsh-theme" "$ZSH_CUSTOM/themes/spaceship.zsh-theme"
