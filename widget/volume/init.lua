local awful = require("awful")
local wibox = require("wibox")
local clickable_container = require("widget.material.clickable-container")
local watch = require("awful.widget.watch")
local dpi = require("beautiful").xresources.apply_dpi

local HOME = os.getenv("HOME")
local PATH_TO_ICONS = HOME .. "/.config/awesome/theme/icons/"

local volume = 0

watch([[bash -c "amixer -D pulse sget Master"]], 1, function(_, stdout)
	local mute = string.match(stdout, "%[(o%D%D?)%]")
	volume = string.match(stdout, "(%d?%d?%d)%%")
	collectgarbage("collect")
end)

local volume_meter = wibox.widget({
	{
		id = "icon",
		widget = wibox.widget.imagebox,
		resize = true,
	},
	layout = wibox.layout.align.horizontal,
})
volume_meter.icon:set_image(PATH_TO_ICONS .. "volume-high.svg")

local widget_button = clickable_container(wibox.container.margin(volume_meter, dpi(4), dpi(4), dpi(4), dpi(4)))

awful.tooltip({
	objects = { widget_button },
	mode = "outside",
	align = "right",
	timer_function = function()
		return "Volume: " .. volume .. "%"
	end,
	preferred_positions = { "right", "left", "top", "bottom" },
	margin_leftright = dpi(1),
	margin_topbottom = dpi(8),
})

return widget_button
