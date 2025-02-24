local awful = require("awful")
local dpi = require("beautiful").xresources.apply_dpi
local wibox = require("wibox")
local clickable_container = require("awesome-wm-widgets.material.clickable-container")

-- Create an imagebox widget which will contains an icon indicating which layout we're using.
-- We need one layoutbox per screen.
local LayoutBox = function(s)
	local layoutBox =
		clickable_container(wibox.container.margin(awful.widget.layoutbox(s), dpi(8), dpi(8), dpi(8), dpi(8)))
	layoutBox:buttons(awful.util.table.join(
		awful.button({}, 1, function()
			awful.layout.inc(1)
		end),
		awful.button({}, 3, function()
			awful.layout.inc(-1)
		end),
		awful.button({}, 4, function()
			awful.layout.inc(1)
		end),
		awful.button({}, 5, function()
			awful.layout.inc(-1)
		end)
	))
	return layoutBox
end

return LayoutBox
