#!/bin/bash

DOTFILES_ROOT=$(pwd)
SYMLINKS_ROOT=$DOTFILES_ROOT/symlinks
SUBLIME_SETTINGS=~/Library/Application\ Support/Sublime\ Text\ 3/Packages/User

echo "Install Homebrew and essential packages"
sh install/brew.sh
echo "Install ohmyzsh"
sh install/ohmyzsh.sh
echo "Install sublime package manager"
sh install/sublime.sh
echo "Install git aliases"
sh install/git.sh

echo "Creating symlinks"
ln -vsf "$SYMLINKS_ROOT/zshrc" ~/.zshrc
rm -r "$SUBLIME_SETTINGS"
ln -vsf "$DOTFILES_ROOT/sublime" "$SUBLIME_SETTINGS"
