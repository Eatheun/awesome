-- MODULE AUTO-START
-- Run all the apps listed in configuration/apps.lua as run_on_start_up only once when awesome start

local awful = require("awful")
local apps = require("configuration.apps")
local lock_cmd = require("module.lock_cmds").lock_cmd2

local function run_once(cmd)
	local findme = cmd
	local firstspace = cmd:find(" ")
	if firstspace then
		findme = cmd:sub(0, firstspace - 1)
	end
	awful.spawn.with_shell(string.format("pgrep -u $USER -x %s > /dev/null || (%s)", findme, cmd))

	-- transfer sleep
	awful.spawn.with_shell("xss-lock --transfer-sleep-lock -- " .. lock_cmd)
	-- swap caps and esc (only activate for traditional kbs)
	-- awful.spawn.with_shell("/usr/bin/setxkbmap -option 'caps:swapescape'")
end

for _, app in ipairs(apps.run_on_start_up) do
	run_once(app)
end
