-------------------------------------------------
-- Brightness Widget for Awesome Window Manager
-- Shows the brightness level of the laptop display
-- More details could be found here:
-- https://github.com/streetturtle/awesome-wm-widgets/tree/master/brightness-widget

-- @author Pavel Makhov
-- @copyright 2021 Pavel Makhov
-------------------------------------------------

local awful = require("awful")
local wibox = require("wibox")
local watch = require("awful.widget.watch")
local spawn = require("awful.spawn")
local gears = require("gears")
local naughty = require("naughty")
local beautiful = require("beautiful")
local recolor_icon = require("awesome-wm-widgets.recolor-icon")
local colors = require("theme.mat-colors").color_palette

local ICON_DIR = "/layout/bars/stats-bar/brightness-widget/"
local get_brightness_cmd
local set_brightness_cmd
local inc_brightness_cmd
local dec_brightness_cmd

local brightness_widget = {}

local function show_warning(message)
	naughty.notify({
		preset = naughty.config.presets.critical,
		title = "Brightness Widget",
		text = message,
	})
end

local function worker(user_args)
	local args = user_args or {}

	local type = args.type or "arc" -- arc or icon_and_text
	local path_to_icon = args.path_to_icon or ICON_DIR .. "brightness.svg"
	local font = args.font or beautiful.font
	local arc_thickness = args.arc_thickness or 2
	local main_color = args.main_color or beautiful.fg_color
	local timeout = args.timeout or 100
	local paddings = args.paddings or 4
	local word_spacing = args.word_spacing or 2

	local program = args.program or "light"
	local step = args.step or 5
	local base = args.base or 20
	local current_level = 0 -- current brightness value
	local height = args.height or 18
	local width = args.width or 18
	local tooltip = args.tooltip or false
	local position = args.notification_position or "top_right"
	local percentage = args.percentage or true
	local rmb_set_max = args.rmb_set_max or false
	if program == "light" then
		get_brightness_cmd = "light -G"
		set_brightness_cmd = "light -S %d" -- <level>
		inc_brightness_cmd = "light -A " .. step
		dec_brightness_cmd = "light -U " .. step
	elseif program == "xbacklight" then
		get_brightness_cmd = "xbacklight -get"
		set_brightness_cmd = "xbacklight -set %d" -- <level>
		inc_brightness_cmd = "xbacklight -inc " .. step
		dec_brightness_cmd = "xbacklight -dec " .. step
	elseif program == "brightnessctl" then
		get_brightness_cmd = "sh -c 'brightnessctl -m | cut -d, -f4 | tr -d %'"
		set_brightness_cmd = "brightnessctl set %d%%" -- <level>
		inc_brightness_cmd = "brightnessctl set +" .. step .. "%"
		dec_brightness_cmd = "brightnessctl set " .. step .. "-%"
	else
		show_warning(program .. " command is not supported by the widget")
		return
	end

	local icon_widget = require("awesome-wm-widgets.icon-text-template.icon")({ size = height })
	local level_widget = require("awesome-wm-widgets.icon-text-template.text")({ font = font })

	if type == "icon_and_text" then
		brightness_widget.widget = wibox.widget({
			icon_widget,
			level_widget,
			spacing = word_spacing,
			max_value = 100,
			forced_height = height,
			forced_width = width,
			paddings = paddings,
			colors = { main_color },
			layout = wibox.layout.fixed.horizontal,
			set_value = function(self, level)
				local display_level = level
				if percentage then
					display_level = display_level .. "%"
				end
				self:get_children_by_id("txt")[1]:set_text(display_level)
			end,
		})
	elseif type == "arc" then
		brightness_widget.widget = wibox.widget({
			icon_widget,
			max_value = 100,
			thickness = arc_thickness,
			start_angle = 4.71238898, -- 2pi*3/4
			forced_height = height,
			forced_width = width,
			paddings = paddings,
			colors = { main_color },
			widget = wibox.container.arcchart,
			set_value = function(self, level)
				self:set_value(level)
			end,
		})
	else
		show_warning(type .. " type is not supported by the widget")
		return
	end

	local update_widget = function(widget, stdout, _, _, _)
		local brightness_level = tonumber(string.format("%.0f", stdout))
		current_level = brightness_level
		widget:set_value(brightness_level)
		local recolored_icon = recolor_icon(path_to_icon, colors.color_dark)
		widget:get_children_by_id("icon")[1].image = recolored_icon
	end

	function brightness_widget:set(value)
		current_level = value
		spawn.easy_async(string.format(set_brightness_cmd, value), function()
			spawn.easy_async_with_shell(get_brightness_cmd, function(out)
				update_widget(brightness_widget.widget, out)
			end)
		end)
	end
	local old_level = 0
	function brightness_widget:toggle()
		if rmb_set_max then
			brightness_widget:set(100)
		else
			if old_level < 0.1 then
				-- avoid toggling between '0' and 'almost 0'
				old_level = 1
			end
			if current_level < 0.1 then
				-- restore previous level
				current_level = old_level
			else
				-- save current brightness for later
				old_level = current_level
				current_level = 0
			end
			brightness_widget:set(current_level)
		end
	end
	function brightness_widget:inc()
		spawn.easy_async(inc_brightness_cmd, function()
			spawn.easy_async_with_shell(get_brightness_cmd, function(out)
				update_widget(brightness_widget.widget, out)
			end)
		end)
	end
	function brightness_widget:dec()
		spawn.easy_async(dec_brightness_cmd, function()
			spawn.easy_async_with_shell(get_brightness_cmd, function(out)
				update_widget(brightness_widget.widget, out)
			end)
		end)
	end

	brightness_widget.widget:buttons(awful.util.table.join(
		awful.button({}, 1, function()
			brightness_widget:inc()
		end),
		awful.button({}, 2, function()
			brightness_widget:set(base)
		end),
		awful.button({}, 3, function()
			brightness_widget:dec()
		end),
		awful.button({}, 4, function()
			brightness_widget:inc()
		end),
		awful.button({}, 5, function()
			brightness_widget:toggle()
		end)
	))

	watch(get_brightness_cmd, timeout, update_widget, brightness_widget.widget)

	if tooltip then
		awful.tooltip({
			objects = { brightness_widget.widget },
			timeout = 5,
			hover_timeout = 0.5,
			margin_leftright = word_spacing * 2,
			margin_topbottom = word_spacing * 2,
			shape = function(cr, w, h)
				gears.shape.rounded_rect(cr, w, h, 24)
			end,
			position = position,
			timer_function = function()
				return "Brightness at " .. current_level .. " %"
			end,
		})
	end

	return brightness_widget.widget
end

return setmetatable(brightness_widget, {
	__call = function(_, ...)
		return worker(...)
	end,
})
