# Add `~/bin` to the `$PATH`
export PATH="$HOME/bin:$PATH"

# Only load xresources if we have an X display defined.
if [[ -n ${DISPLAY} ]]; then
	xrdb -merge ~/dotfiles/xresources
fi


[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*

# The next line updates PATH for the Google Cloud SDK.
source '/Users/simon/google-cloud-sdk/path.bash.inc'

# The next line enables bash completion for gcloud.
source '/Users/simon/google-cloud-sdk/completion.bash.inc'
