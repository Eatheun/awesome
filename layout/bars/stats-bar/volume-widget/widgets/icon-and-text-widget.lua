local wibox = require("wibox")
local beautiful = require("beautiful")
local recolor_icon = require("awesome-wm-widgets.recolor-icon")
local colors = require("theme.mat-colors").color_palette

local widget = {}

local ICON_DIR = "/layout/bars/stats-bar/volume-widget/icons/"

function widget.get_widget(widgets_args)
	local args = widgets_args or {}

	local font = args.font or beautiful.font
	local icon_dir = args.icon_dir or ICON_DIR
	local main_color = args.main_color or beautiful.fg_color
	local bg_color = args.bg_color or "#ffffff11"
	local mute_color = args.mute_color or beautiful.fg_urgent
	local height = args.height or 18
	local width = args.width or 18
	local paddings = args.paddings or 4
	local word_spacing = args.word_spacing or 2

	local icon_widget = require("awesome-wm-widgets.icon-text-template.icon")({ size = height })
	local level_widget = require("awesome-wm-widgets.icon-text-template.text")({ font = font })

	return wibox.widget({
		icon_widget,
		level_widget,
		spacing = word_spacing,
		layout = wibox.layout.fixed.horizontal,
		max_value = 100,
		forced_height = height,
		forced_width = width,
		bg = bg_color,
		paddings = paddings,
		widget = wibox.container.arcchart,
		set_volume_level = function(self, new_value)
			self:get_children_by_id("txt")[1]:set_text(new_value .. "%")
			local volume_icon_name
			if self.is_muted then
				volume_icon_name = "audio-volume-muted-symbolic"
			else
				local new_value_num = tonumber(new_value)
				if new_value_num >= 0 and new_value_num < 33 then
					volume_icon_name = "audio-volume-low-symbolic"
				elseif new_value_num < 66 then
					volume_icon_name = "audio-volume-medium-symbolic"
				else
					volume_icon_name = "audio-volume-high-symbolic"
				end
			end

			local new_image = recolor_icon(icon_dir .. volume_icon_name .. ".svg", colors.color_light)
			self:get_children_by_id("icon")[1].image = new_image
		end,
		mute = function(self)
			self.is_muted = true
			self.colors = { mute_color }

			local new_image = recolor_icon(icon_dir .. "audio-volume-muted-symbolic.svg", colors.color_light)
			self:get_children_by_id("icon")[1].image = new_image
		end,
		unmute = function(self)
			self.is_muted = false
			self.colors = { main_color }
		end,
	})
end

return widget
