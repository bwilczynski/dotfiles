#!/bin/bash

type brew >/dev/null 2>&1 || {
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
}

brew install autojump
brew install git
brew install python
brew install rbenv
brew install task
brew install xtail

brew install caskroom/cask/brew-cask

brew cask install sublime-text
brew cask install avast
brew cask install google-chrome
brew cask install iterm2
brew cask install flux
