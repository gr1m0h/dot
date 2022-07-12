local wezterm = require 'wezterm';

return {
	color_scheme = 'Dracula',
	window_background_opacity = 0.8,
	keys = {
    		-- This will create a new split and run your default program inside it
    		{ key = 'd', mods = 'CMD',
          action = wezterm.action{ SplitHorizontal = { domain = 'CurrentPaneDomain' }}},
	},
	exit_behavior = "Close"
}
