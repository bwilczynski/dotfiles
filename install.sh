#!/bin/bash

DOTFILES_ROOT=$(pwd)
SYMLINKS_ROOT=$DOTFILES_ROOT/symlinks

sh install/braw.sh
sh install/ohmyzsh.sh

ln -sf $SYMLINKS_ROOT/zshrc ~/.zshrc
ln -sf $DOTFILES_ROOT/sublime ~/Library/Application\ Support/Sublime\ Text\ 3/Packages/User
