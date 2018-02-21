#!/bin/bash

DOTFILES_ROOT=$(pwd)
SYMLINKS_ROOT=$DOTFILES_ROOT/symlinks

echo "Install Homebrew and essential packages"
sh install/brew.sh
echo "Install ohmyzsh"
sh install/ohmyzsh.sh
echo "Install git aliases"
sh install/git.sh

echo "Creating symlinks"
ln -vsf "$SYMLINKS_ROOT/zshrc" ~/.zshrc
ln -vsf "$SYMLINKS_ROOT/vimrc" ~/.vimrc
ln -vsf "$SYMLINKS_ROOT/p4merge.dms" /usr/local/bin/p4merge
