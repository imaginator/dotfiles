dotfiles
========


local changes -> master

`git commit`


master -> local machine

`bootstrap.sh`

Making things more like $HOME
=============================
```bash
apt-get install git tmux zsh
scp -r simon@bunker.imaginator.com:~/.ssh ~
cd ~ && git clone git://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh
cd ~ && git clone git@github.com:imaginator/dotfiles.git
./dotfiles/bootstrap.sh
sudo chsh -s  /usr/bin/zsh
zsh
```
