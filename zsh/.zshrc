# Path to your oh-my-zsh configuration.
ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
ZSH_THEME="agnoster"
DEFAULT_USER="simon"

# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
alias 'dus=du -sckx * | sort -nr'


# Set to this to use case-sensitive completion
# CASE_SENSITIVE="true"

# Comment this out to disable weekly auto-update checks
# DISABLE_AUTO_UPDATE="true"

# Uncomment following line if you want to disable colors in ls
# DISABLE_LS_COLORS="true"

# Uncomment following line if you want to disable autosetting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment following line if you want red dots to be displayed while waiting for completion
COMPLETION_WAITING_DOTS="true"

# When running tmux automatically connect to the currently running tmux session if it exits, otherwise start a new session. Set to true by default.
ZSH_TMUX_AUTOCONNECT="true"

# Close the terminal session when tmux exits. Set to the value of
ZSH_TMUX_AUTOQUIT="true"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
plugins=(adb command-not-found colorize colored-man-pages git debian brew kubectl docker tmux pip history-substring-search pyenv kubectl zsh-autosuggestions zsh-syntax-highlighting) 
# for plugin:colorize
ZSH_COLORIZE_STYLE="colorful"

source $ZSH/oh-my-zsh.sh

# Customize to your needs...
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"
export EDITOR=/usr/bin/vim
export LESS='-F -g -i -M -R -S -w -X -z-4'   # command line options for less

[ -x "$(command -v kubectl)" ] && source <(kubectl completion zsh)
[ -x "$(command -v helm)" ] && source <(helm completion zsh)


