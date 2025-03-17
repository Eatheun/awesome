local gfs = require("gears").filesystem
local img_path = gfs.get_configuration_dir() .. "module/lock-screen.png"

return {
	lock_cmd1 = "i3lock-fancy -p",
	lock_cmd2 = "i3lock --image " .. img_path .. " --pointer=default --nofork",
}
