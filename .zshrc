# Path to your oh-my-zsh configuration.
ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
ZSH_THEME="robbyrussell"

# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# Set to this to use case-sensitive completion
# CASE_SENSITIVE="true"

# Comment this out to disable weekly auto-update checks
# DISABLE_AUTO_UPDATE="true"

# Uncomment following line if you want to disable colors in ls
# DISABLE_LS_COLORS="true"

# Uncomment following line if you want to disable autosetting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment following line if you want red dots to be displayed while waiting for completion
# COMPLETION_WAITING_DOTS="true"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
plugins=(git rvm debian rails tmux)

source $ZSH/oh-my-zsh.sh

# Customize to your needs...
export PATH=$PATH:/sbin:/usr/sbin:/usr/local/sbin:/usr/local/bin:/bin:/usr/bin:/usr/X11R6/bin:/usr/games:/usr/local/games:/usr/local/java/bin:/usr/local/Cellar/ruby/2.0.0-p247/bin:/home/simon/bin:~/.rvm/bin:

export PERL_LOCAL_LIB_ROOT="/home/simon/perl5";
export PERL_MB_OPT="--install_base /home/simon/perl5";
export PERL_MM_OPT="INSTALL_BASE=/home/simon/perl5";
export PERL5LIB="/home/simon/perl5/lib/perl5/x86_64-linux-gnu-thread-multi:/home/simon/perl5/lib/perl5";
export PATH="/home/simon/perl5/bin:$PATH";

[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm"  # This loads RVM into a shell session.

