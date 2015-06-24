#!/usr/bin/env bash
#cd "(dirname "${BASH_SOURCE}")"
cd ~/dotfiles

git pull 
git submodule init
git submodule update

for dotfile in  `find ~/dotfiles -maxdepth 1 ! \( -name ".git" -o -name "README.md" -o -name "bootstrap.sh" -o -name ".DS_Store" -o -name "dotfiles" -o -name ".gitignore" \)  -exec basename {} \;`
do
  if [ -L ~/"$dotfile" ]
  then
    echo "$dotfile: ok"
  elif [ -f ~/"$dotfile" ] || [ -d ~/"$dotfile" ]
  then
    echo "$dotfile: a file or directory already exists here. Remove so it can be automatically symlinkd"
  else
    ln -s ~/dotfiles/$dotfile ~/$dotfile
    echo "$dotfile symlined into place"
  fi
done

if [ ! -d "~/.ssh" ] ; then
  mkdir ~/.ssh
fi

cp .ssh-public-key/id_dsa.pub ~/.ssh/authorized_keys
cp .ssh-public-key/id_dsa.pub ~/.ssh/id_dsa.pub
