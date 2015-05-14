#!/bin/bash

DOTFILES_ROOT=$(pwd)
SYMLINKS_ROOT=$DOTFILES_ROOT/symlinks
SUBLIME_SETTINGS=~/Library/Application\ Support/Sublime\ Text\ 3/Packages/User

sh install/braw.sh
sh install/ohmyzsh.sh

ln -vsf "${SYMLINKS_ROOT}/zshrc" ~/.zshrc
rm -r "${SUBLIME_SETTINGS}"
ln -vsf "${DOTFILES_ROOT}/sublime" "${SUBLIME_SETTINGS}"
