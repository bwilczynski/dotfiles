#!/bin/bash

git config --global alias.cp cherry-pick
git config --global alias.st status
git config --global alias.ci commit
git config --global alias.br branch
git config --global alias.co checkout
git config --global alias.cob 'checkout -b'
git config --global alias.df diff
git config --global alias.lg 'log --graph --oneline --all --decorate'
git config --global alias.cm '!git add -A && git commit -m'
git config --global alias.branch-name '!git symbolic-ref --short HEAD'
git config --global alias.publish '!git push -u origin $(git branch-name)'
git config --global alias.unpublish '!git push origin :$(git branch-name)'
git config --global alias.cleanup '!git branch --merged | grep  -v "\\*\\|master\\|develop" | xargs -n 1 git branch -d'
git config --global alias.purr 'pull --rebase'
git config --global alias.puff 'pull --ff-only'
git config --global alias.cobf '!f() { git checkout -b feature/$1; }; f'
git config --global merge.tool p4merge
git config --global mergetool.keepTemporaries false
git config --global mergetool.prompt false
