#!/bin/bash
set -xe


# Get the number of outputs
outputs=$(swaymsg -t get_outputs)

# Exit in case we are not docked, e.g. no external monitors found
output_count=$(echo $outputs | jq '. | length')

if [ $output_count -ne 3 ]; then
	exit
fi

# Build matching table
declare -A out_table
out_table["b595bb38aefeb87b16fca094b9faf0710417c48604380790647f558acd4ec439"]="left"
out_table["bbe640632508e09a954fc8d55936f8ab64f256d6ba1500dfd9223416450356f4"]="right"

# Get external output names
readarray -t external_outputs <<<$(echo $outputs | jq -r '.[] | select(.name != "eDP-1") | .name')

# Calculate sha256 sums of edids
external_0=$(sha256sum /sys/class/drm/card0-${external_outputs[0]}/edid | awk '{ print $1 }' )
external_1=$(sha256sum /sys/class/drm/card0-${external_outputs[1]}/edid | awk '{ print $1 }' )

# Match outputs to left / right
m_internal="eDP-1"

if [ ${out_table[$external_0]} == "left" ]; then
	l_external=${external_outputs[0]}
	r_external=${external_outputs[1]}
else
	l_external=${external_outputs[1]}
	r_external=${external_outputs[0]}
fi

internal_active=$(echo $outputs | jq '.[] | select(.name == "eDP-1") | (.active)')

# Switch monitors
if [ $internal_active == "true" ]; then

	echo "Internal active, switching to external"
	
	swaymsg output $l_external enable mode 2560x2160 scale 1 pos 0 0    
	swaymsg output $r_external enable mode 2560x2160 scale 1 pos 2560 0 
	swaymsg output $m_internal enable mode 2560x1440 scale 1 pos 5120 1221 

	# Moving the workspaces needs to be done first
	swaymsg "workspace 1, move workspace to output "$l_external
	swaymsg "workspace 4, move workspace to output "$l_external
	swaymsg "workspace 7, move workspace to output "$l_external
	swaymsg "workspace 2, move workspace to output "$r_external
	swaymsg "workspace 5, move workspace to output "$r_external
	swaymsg "workspace 8, move workspace to output "$r_external
	swaymsg "workspace 3, move workspace to output "$m_internal
	swaymsg "workspace 6, move workspace to output "$m_internal 
	swaymsg "workspace 9, move workspace to output "$m_internal 

	swaymsg "workspace 1 output "$l_external
	swaymsg "workspace 4 output "$l_external
	swaymsg "workspace 7 output "$l_external
	swaymsg "workspace 2 output "$r_external
	swaymsg "workspace 5 output "$r_external
	swaymsg "workspace 8 output "$r_external
	swaymsg "workspace 3 output "$m_internal
	swaymsg "workspace 6 output "$m_internal
	swaymsg "workspace 9 output "$m_internal

	# Go to the first workspace on each output
	swaymsg "workspace 3"
	swaymsg "workspace 2"
	swaymsg "workspace 1"
	
	notify-send 'Display Mode' 'Home' --icon=dialog-information

else
	echo "Internal inactive, switching to internal"

	swaymsg output $l_external disable
	swaymsg output $r_external disable
	swaymsg output $m_internal enable scale 1 pos 0 0
	
	swaymsg "workspace 1"
	
	notify-send 'Display Mode' 'Laptop' --icon=dialog-information
fi
