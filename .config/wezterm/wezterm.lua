local wezterm = require 'wezterm';

return {
  color_scheme = 'Dracula',
  keys = {
        -- This will create a new split and run your default program inside it
        { key = 'd', mods = 'CMD',
          action = wezterm.action{ SplitHorizontal = { domain = 'CurrentPaneDomain' }}},
  },
  exit_behavior = 'Close',
	font = wezterm.font 'UDEV Gothic',
	font_size = 13.0,
	use_ime = true,
}
