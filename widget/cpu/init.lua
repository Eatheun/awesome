local awful = require("awful")
local wibox = require("wibox")
local clickable_container = require("widget.material.clickable-container")
local gears = require("gears")
local watch = require("awful.widget.watch")
local dpi = require("beautiful").xresources.apply_dpi

local HOME = os.getenv("HOME")
local PATH_TO_ICONS = HOME .. "/.config/awesome/theme/icons/"

local total_prev = 0
local idle_prev = 0

local usage = 0

watch([[bash -c "cat /proc/stat | grep '^cpu '"]], 1, function(_, stdout)
	local user, nice, system, idle, iowait, irq, softirq, steal, guest, guest_nice =
		stdout:match("(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s")

	local total = user + nice + system + idle + iowait + irq + softirq + steal

	local diff_idle = idle - idle_prev
	local diff_total = total - total_prev
	local diff_usage = (1000 * (diff_total - diff_idle) / diff_total + 5) / 10

	usage = math.floor(diff_usage + 0.5)

	total_prev = total
	idle_prev = idle
	collectgarbage("collect")
end)

local cpu_meter = wibox.widget({
	{
		id = "icon",
		widget = wibox.widget.imagebox,
		resize = true,
	},
	layout = wibox.layout.align.horizontal,
})
cpu_meter.icon:set_image(PATH_TO_ICONS .. "cpu.svg")

local widget_button = clickable_container(wibox.container.margin(cpu_meter, dpi(4), dpi(4), dpi(4), dpi(4)))
widget_button:buttons(gears.table.join(awful.button({}, 1, nil, function()
	awful.spawn("mate-system-monitor")
end)))

awful.tooltip({
	objects = { widget_button },
	mode = "outside",
	align = "right",
	timer_function = function()
		return "CPU at " .. usage .. "% utilisation"
	end,
	preferred_positions = { "right", "left", "top", "bottom" },
	margin_leftright = dpi(1),
	margin_topbottom = dpi(8),
})

return widget_button
