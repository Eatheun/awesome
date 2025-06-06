local filesystem = require("gears.filesystem")

-- Thanks to jo148 on github for making rofi dpi aware!
local with_dpi = require("beautiful").xresources.apply_dpi
local get_dpi = require("beautiful").xresources.get_dpi
local rofi_command = "env /usr/bin/rofi -dpi "
	.. get_dpi()
	.. " -width "
	.. with_dpi(400)
	.. " -show drun -theme "
	.. filesystem.get_configuration_dir()
	.. "/configuration/rofi.rasi -run-command \"/bin/bash -c -i 'shopt -s expand_aliases; {cmd}'\""
local lock_cmd = require("module.lock_cmds").lock_cmd2

return {
	-- List of apps to start by default on some actions
	default = {
		terminal = "terminator",
		rofi = rofi_command,
		lock = lock_cmd,
		screenshot = "flameshot screen -p ~/Pictures | xclip",
		region_screenshot = "flameshot gui",
		delayed_screenshot = "flameshot screen -p ~/Pictures -d 5000",
		entire_screenshot = "flameshot full -c",
		browser = "vivaldi",
		editor = "nvim", -- gui text editor
		social = "discord",
		files = "nautilus",
	},
	-- List of apps to start once on start-up
	run_on_start_up = {
		"picom --config " .. filesystem.get_configuration_dir() .. "/configuration/compositor.conf",
		-- "polybar -q tag_bar",
		"nm-applet --indicator", -- wifi
		"pnmixer", -- shows an audiocontrol applet in systray when installed.
		"numlockx on", -- enable numlock
		"/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 & eval $(gnome-keyring-daemon -s --components=pkcs11,secrets,ssh,gpg)", -- credential manager
		"xfce4-power-manager", -- Power manager
		"flameshot",
		-- "feh --randomize --bg-fill ~/.wallpapers/*",
		"variety",
		"redshift -P -O 4200",
		-- Add applications that need to be killed between reloads
		-- to avoid multipled instances, inside the awspawn script
		"~/.config/awesome/configuration/awspawn", -- Spawn "dirty" apps that can linger between sessions
	},
}
