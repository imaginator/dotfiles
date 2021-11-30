# My dotfiles

Making things more like $HOME

```bash
sudo apt-get install git tmux zsh vim stow
sudo useradd simon -s /usr/bin/zsh -m -g simon -G sudo,adm,systemd-journal 
sudo -i -u simon
git clone https://github.com/imaginator/dotfiles.git
cd dotfiles
git pull --recurse-submodules --jobs=10
git clone https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh
stow autorandr  bash bin code git htop i3 polybar ssh tmux vim  zsh
zsh

# from another machine
ssh-copy-id -i .ssh/id_simon  simon@<new-machine>
```
