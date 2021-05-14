# My dotfiles

Making things more like $HOME

```bash
# as root
apt-get install git tmux zsh vim
useradd simon -s /usr/bin/zsh -m
mkdir ~simon/.ssh
cat .ssh/authorized_keys  >> ~simon/.ssh/authorized_keys
chown -R simon ~simon/
sudo -i -u simon
git clone https://github.com/imaginator/dotfiles.git
cd dotfiles
stow autorandr  bash  bin  code  git  htop  i3  polybar ssh  tmux  vim  X  zsh
sudo chsh -s  /usr/bin/zsh
zsh
```
