# My dotfiles

Making things more like $HOME

```bash
sudo sh -c 'echo "$(logname) ALL=(ALL:ALL) NOPASSWD: ALL" > /etc/sudoers.d/$(logname)' && sudo chmod 440 /etc/sudoers.d/$(logname)
sudo apt-get install git tmux zsh vim stow htop strace ltrace zsh-syntax-highlighting
sudo update-alternatives --set editor /usr/bin/vim.basic
sudo useradd simon -s /usr/bin/zsh -m -G simon -G sudo
sudo passwd simon
sudo chsh -s /bin/zsh simon 
sudo usermod -a -G sudo,adm,systemd-journal simon
sudo -i -u simon
git clone https://github.com/imaginator/dotfiles.git
cd dotfiles
git pull --recurse-submodules --jobs=10
git clone https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh
stow bin code git htop ssh tmux vim zsh
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
zsh

# from another machine
ssh-copy-id -i .ssh/id_simon  simon@<new-machine>
```

Other things:

keyboard is defined as being `Macintosh ISO layout (International English)`

```bash
gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'us+mac')]"
gsettings set org.gnome.desktop.input-sources xkb-options "['compose:ralt']" # set compose character
```
- For ä you press Compose,", a
- For € you press Compose,=, e
- For £ you press Compose,-, l.
