-------------------------------------------------
-- WiFi Widget for Awesome Window Manager
-- Adapted from battery widget

-- @author Pavel Makhov
-- @copyright 2017 Pavel Makhov
-------------------------------------------------

local awful = require("awful")
local watch = require("awful.widget.watch")
local wibox = require("wibox")
local clickable_container = require("awesome-wm-widgets.material.clickable-container")
local gears = require("gears")
local dpi = require("beautiful").xresources.apply_dpi
local recolor_icon = require("awesome-wm-widgets.recolor-icon")
local colors = require("theme.mat-colors").color_palette

local HOME = os.getenv("HOME")
local PATH_TO_ICONS = HOME .. "/.config/awesome/layout/bars/middle-bar/wifi/icons/"
local connected = false
local essid = "N/A"

local wifi_widget = {}

local function worker(user_args)
	local height = user_args.height or 18
	local paddings = user_args.paddings
	local icon_widget = require("awesome-wm-widgets.icon-text-template.icon")({ size = height * 2 })

	wifi_widget.widget = wibox.widget({
		icon_widget,
		layout = wibox.layout.fixed.horizontal,
	})

	local widget_button = clickable_container(
		wibox.container.margin(wifi_widget.widget, dpi(paddings), dpi(paddings), dpi(paddings), dpi(paddings))
	)
	widget_button:buttons(gears.table.join(awful.button({}, 1, nil, function()
		awful.spawn("nm-connection-editor")
	end)))

	-- Alternative to naughty.notify - tooltip. You can compare both and choose the preferred one
	awful.tooltip({
		objects = { widget_button },
		mode = "outside",
		align = "right",
		timer_function = function()
			if connected then
				return "Connected to " .. essid
			else
				return "Wireless network is disconnected"
			end
		end,
		preferred_positions = { "right", "left", "top", "bottom" },
		margin_leftright = dpi(8),
		margin_topbottom = dpi(8),
	})

	local function grabText()
		if connected then
			awful.spawn.easy_async("iw dev", function(stdout)
				essid = stdout:match("ssid (.-)\n")
				if essid == nil then
					essid = "N/A"
				end
			end)
		end
	end

	watch("awk 'NR==3 {printf \"%3.0f\" ,($3/70)*100}' /proc/net/wireless", 5, function(widget, stdout)
		local widgetIconName = "wifi-strength"
		local wifi_strength = tonumber(stdout)
		connected = wifi_strength ~= nil
		if wifi_strength ~= nil then
			-- Update popup text
			local wifi_strength_rounded = math.floor(wifi_strength / 25 + 0.5)
			widgetIconName = widgetIconName .. "-" .. wifi_strength_rounded
		else
			widgetIconName = widgetIconName .. "-off"
		end

		local new_image =
			recolor_icon("/layout/bars/middle-bar/wifi/icons/" .. widgetIconName .. ".svg", colors.color_dark)
		widget:get_children_by_id("icon")[1].image = new_image

		if connected and (essid == "N/A" or essid == nil) then
			grabText()
		end
		collectgarbage("collect")
	end, wifi_widget.widget)

	wifi_widget.widget:connect_signal("mouse::enter", function()
		grabText()
	end)

	return widget_button
end

return setmetatable(wifi_widget, {
	__call = function(_, ...)
		return worker(...)
	end,
})
