for i in {1..9}; do gsettings set "org.gnome.shell.keybindings"      "switch-to-application-$i" "[]"; done
for i in {1..9}; do gsettings set "org.gnome.desktop.wm.keybindings" "switch-to-workspace-$i" "['<super>$i']"; done

gsettings set org.gnome.desktop.datetime automatic-timezone true
gsettings set org.gnome.desktop.interface show-battery-percentage true
gsettings set org.gnome.desktop.session idle-delay 600

gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-1 "['<Super>1']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-2 "['<Super>2']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-3 "['<Super>3']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-4 "['<Super>4']"
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-left "[]"
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-right "[]"


gsettings set org.gnome.settings-daemon.plugins.power power-button-action 'suspend'
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-timeout 3600
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-timeout 5400
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'suspend'

gsettings set org.gnome.desktop.input-sources xkb-options "['compose:ralt']"


gnome-extensions disable ding@rastersoft.com      # disable desktop icons 
gnome-extensions disable ubuntu-dock@ubuntu.com
