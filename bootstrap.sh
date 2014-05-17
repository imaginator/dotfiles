#!/usr/bin/env bash
#cd "(dirname "${BASH_SOURCE}")"
cd ~/dotfiles
#git pull origin master

for dotfile in  `find ~/dotfiles -not -name '.git' -not -name 'README.md' -not -name 'bootstrap.sh' -not -name ".DS_Store" -depth 1 -exec basename {} \;`
do
  echo "$dotfile to be replaced"
  if [ ! -L ~/"$dotfile" ]
    then
    echo "$dotfile is not a symlink. Stopping."
    exit 0
  fi
  unlink ~/$dotfile
  ln -s ~/dotfiles/$dotfile ~/$dotfile
done

