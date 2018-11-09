#!/bin/bash

type brew >/dev/null 2>&1 || {
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
}

brew install autojump
brew install git
brew install python
brew install rbenv

