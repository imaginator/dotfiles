# My dotfiles

Making things more like $HOME

```bash
sudo apt-get install git tmux zsh vim stow htop strace ltrace
sudo useradd simon -s /usr/bin/zsh -m -G simon -G sudo
sudo passwd simon
sudo chsh -s /bin/zsh simon 
sudo usermod -a -G sudo,adm,systemd-journal simon
sudo sh -c 'echo "$(logname) ALL=(ALL:ALL) NOPASSWD: ALL" > /etc/sudoers.d/$(logname)' && sudo chmod 440 /etc/sudoers.d/$(logname)
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
