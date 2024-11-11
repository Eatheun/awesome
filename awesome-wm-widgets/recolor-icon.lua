local gears = require("gears")
local gfs = gears.filesystem
return function(icon_path, color)
	local icon = gears.surface.load_uncached(gfs.get_configuration_dir() .. icon_path)
	local icon_recolored = gears.color.recolor_image(icon, color)
	return icon_recolored
end
