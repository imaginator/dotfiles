# My dotfiles

Making things more like $HOME

```bash
# as root
apt-get install git tmux zsh
useradd simon -s /usr/bin/zsh -m
mkdir ~simon/.ssh
cat .ssh/authorized_keys  >> ~simon/.ssh/authorized_keys
chown -R simon ~simon/
sudo -i -u simon
git clone https://github.com/imaginator/dotfiles.git
~/dotfiles/bootstrap.sh
sudo chsh -s  /usr/bin/zsh
zsh
```
