-------------------------------------------------
-- Battery Widget for Awesome Window Manager
-- Shows the battery status using the ACPI tool
-- More details could be found here:
-- https://github.com/streetturtle/awesome-wm-widgets/tree/master/battery-widget

-- @author Pavel Makhov
-- @copyright 2017 Pavel Makhov
-------------------------------------------------

local awful = require("awful")
local naughty = require("naughty")
local watch = require("awful.widget.watch")
local wibox = require("wibox")
local beautiful = require("beautiful")
local gears = require("gears")
local gfs = require("gears.filesystem")
local dpi = require("beautiful").xresources.apply_dpi
local recolor_icon = require("awesome-wm-widgets.recolor-icon")
local colors = require("theme.mat-colors").color_palette

-- acpi sample outputs
-- Battery 0: Discharging, 75%, 01:51:38 remaining
-- Battery 0: Charging, 53%, 00:57:43 until charged

local WIDGET_DIR = "/awesome-wm-widgets/battery-widget"

local battery_widget = {}
local function worker(user_args)
	local args = user_args or {}

	local font = args.font or beautiful.font
	local path_to_icons = args.path_to_icons or "/awesome-wm-widgets/battery-widget/"
	local show_current_level = args.show_current_level or true
	local margin_left = args.margin_left or 0
	local margin_right = args.margin_right or 0
	local word_spacing = args.word_spacing or 2
	local height = args.height or 18
	local width = args.width or 18

	local display_notification = args.display_notification or false
	local display_notification_onClick = args.display_notification_onClick or true
	local position = args.notification_position or "top_right"
	local timeout = args.timeout or 10

	local warning_msg_title = args.warning_msg_title or "Huston, we have a problem"
	local warning_msg_text = args.warning_msg_text or "Battery is dying"
	local warning_msg_position = args.warning_msg_position or "bottom_right"
	local warning_msg_icon = args.warning_msg_icon or WIDGET_DIR .. "/spaceman.jpg"
	local enable_battery_warning = args.enable_battery_warning
	if enable_battery_warning == nil then
		enable_battery_warning = true
	end

	local icon_widget = wibox.widget(require("awesome-wm-widgets.icon-text-template.icon")({ size = height }))
	local level_widget = wibox.widget(require("awesome-wm-widgets.icon-text-template.text")({ font = font }))

	battery_widget = wibox.widget({
		icon_widget,
		level_widget,
		spacing = word_spacing,
		forced_height = height,
		forced_width = width,
		layout = wibox.layout.fixed.horizontal,
	})
	-- Popup with battery info
	-- One way of creating a pop-up notification - naughty.notify
	local notification
	local function show_battery_status(batteryType)
		awful.spawn.easy_async([[bash -c 'acpi']], function(stdout, _, _, _)
			naughty.destroy(notification)
			notification = naughty.notify({
				text = stdout,
				title = "Battery status",
				-- icon = "~/.config/awesome" .. path_to_icons .. batteryType .. ".svg",
				-- icon_size = dpi(16),
				position = position,
				timeout = 5,
				hover_timeout = 0.5,
				width = 200,
				screen = mouse.screen,
				shape = function(cr, w, h)
					gears.shape.rounded_rect(cr, w, h, 24)
				end,
			})
		end)
	end

	local function show_battery_warning()
		naughty.notify({
			icon = warning_msg_icon,
			icon_size = 100,
			text = warning_msg_text,
			title = warning_msg_title,
			timeout = 25, -- show the warning for a longer time
			hover_timeout = 0.5,
			position = warning_msg_position,
			bg = colors.color_dark2,
			fg = colors.color_light,
			width = 300,
			screen = mouse.screen,
		})
	end
	local last_battery_check = os.time()
	local batteryType = "battery-good-symbolic"

	watch("acpi -i", timeout, function(widget, stdout)
		local battery_info = {}
		local capacities = {}
		for s in stdout:gmatch("[^\r\n]+") do
			-- Match a line with status and charge level
			local status, charge_str, _ = string.match(s, ".+: ([%a%s]+), (%d?%d?%d)%%,?(.*)")
			if status ~= nil then
				-- Enforce that for each entry in battery_info there is an
				-- entry in capacities of zero. If a battery has status
				-- "Unknown" then there is no capacity reported and we treat it
				-- as zero capactiy for later calculations.
				table.insert(battery_info, { status = status, charge = tonumber(charge_str) })
				table.insert(capacities, 0)
			end

			-- Match a line where capacity is reported
			local cap_str = string.match(s, ".+:.+last full capacity (%d+)")
			if cap_str ~= nil then
				capacities[#capacities] = tonumber(cap_str) or 0
			end
		end

		local capacity = 0
		local charge = 0
		local status
		for i, batt in ipairs(battery_info) do
			if capacities[i] ~= nil then
				if batt.charge >= charge then
					status = batt.status -- use most charged battery status
					-- this is arbitrary, and maybe another metric should be used
				end

				-- Adds up total (capacity-weighted) charge and total capacity.
				-- It effectively ignores batteries with status "Unknown" as we
				-- treat them with capacity zero.
				charge = charge + batt.charge * capacities[i]
				capacity = capacity + capacities[i]
			end
		end
		charge = charge / capacity

		if show_current_level then
			level_widget.text = string.format("%d%%", charge)
		end

		if charge >= 1 and charge < 15 then
			batteryType = "battery-empty%s-symbolic"
			if enable_battery_warning and status ~= "Charging" and os.difftime(os.time(), last_battery_check) > 300 then
				-- if 5 minutes have elapsed since the last warning
				last_battery_check = os.time()

				show_battery_warning()
			end
		elseif charge >= 15 and charge < 40 then
			batteryType = "battery-caution%s-symbolic"
		elseif charge >= 40 and charge < 60 then
			batteryType = "battery-low%s-symbolic"
		elseif charge >= 60 and charge < 80 then
			batteryType = "battery-good%s-symbolic"
		elseif charge >= 80 and charge <= 100 then
			batteryType = "battery-full%s-symbolic"
		end

		if status == "Charging" then
			batteryType = string.format(batteryType, "-charging")
		else
			batteryType = string.format(batteryType, "")
		end

		local recolored_icon = recolor_icon(path_to_icons .. batteryType .. ".svg", colors.color_light)
		widget.icon.image = recolored_icon
	end, icon_widget)

	if display_notification then
		battery_widget:connect_signal("mouse::enter", function()
			show_battery_status(batteryType)
		end)
		battery_widget:connect_signal("mouse::leave", function()
			naughty.destroy(notification)
		end)
	elseif display_notification_onClick then
		battery_widget:connect_signal("button::press", function(_, _, _, button)
			if button == 3 then
				show_battery_status(batteryType)
			end
		end)
		battery_widget:connect_signal("mouse::leave", function()
			naughty.destroy(notification)
		end)
	end

	return wibox.container.margin(battery_widget, margin_left, margin_right)
end

return setmetatable(battery_widget, {
	__call = function(_, ...)
		return worker(...)
	end,
})
