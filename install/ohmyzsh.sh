#!/bin/bash

OH_MY_ZSH=~/.oh-my-zsh

if [ ! -d "$OH_MY_ZSH" ]; then
  curl -L https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh | sh
fi

cp ohmyzsh/*.zsh "$OH_MY_ZSH/custom/"