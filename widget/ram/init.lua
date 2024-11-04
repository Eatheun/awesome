local awful = require("awful")
local wibox = require("wibox")
local clickable_container = require("widget.material.clickable-container")
local gears = require("gears")
local watch = require("awful.widget.watch")
local dpi = require("beautiful").xresources.apply_dpi

local HOME = os.getenv("HOME")
local PATH_TO_ICONS = HOME .. "/.config/awesome/theme/icons/"

local usage = 0
local total = 0

watch('bash -c "free | grep -z Mem.*Swap.*"', 1, function(_, stdout)
	local totalMem, used, free, shared, buff_cache, available, total_swap, used_swap, free_swap =
		stdout:match("(%d+)%s*(%d+)%s*(%d+)%s*(%d+)%s*(%d+)%s*(%d+)%s*Swap:%s*(%d+)%s*(%d+)%s*(%d+)")
	usage = math.floor(used / 100000 + 0.5) / 10
	total = math.floor(totalMem / 1000000 + 0.5)

	collectgarbage("collect")
end)

local ram_meter = wibox.widget({
	{
		id = "icon",
		widget = wibox.widget.imagebox,
		resize = true,
	},
	layout = wibox.layout.align.horizontal,
})
ram_meter.icon:set_image(PATH_TO_ICONS .. "memory.svg")

local widget_button = clickable_container(wibox.container.margin(ram_meter, dpi(4), dpi(4), dpi(4), dpi(4)))
widget_button:buttons(gears.table.join(awful.button({}, 1, nil, function()
	awful.spawn("mate-system-monitor")
end)))

awful.tooltip({
	objects = { widget_button },
	mode = "outside",
	align = "right",
	timer_function = function()
		return usage .. "Gb used out of " .. total .. "Gb"
	end,
	preferred_positions = { "right", "left", "top", "bottom" },
	margin_leftright = dpi(1),
	margin_topbottom = dpi(8),
})

return widget_button
