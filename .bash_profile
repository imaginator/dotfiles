# Add `~/bin` to the `$PATH`
export PATH="$HOME/bin:$PATH"

# Only load xresources if we have an X display defined.
if [[ -n ${DISPLAY} ]]; then
	xrdb -merge ~/dotfiles/xresources
fi

