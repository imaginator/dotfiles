# My dotfiles

Making things more like $HOME

```bash
sudo apt-get install git tmux zsh vim stow
sudo useradd simon -s /usr/bin/zsh -m -g simon
sudo chsh -s /bin/zsh simon 
sudo usermod -a -G sudo,adm,systemd-journal simon
sudo -i -u simon
git clone https://github.com/imaginator/dotfiles.git
cd dotfiles
git pull --recurse-submodules --jobs=10
git clone https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh
stow bin code git htop ssh tmux vim zsh
zsh

# from another machine
ssh-copy-id -i .ssh/id_simon  simon@<new-machine>
```
