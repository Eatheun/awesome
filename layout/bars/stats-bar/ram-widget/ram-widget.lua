local awful = require("awful")
local beautiful = require("beautiful")
local gears = require("gears")
local watch = require("awful.widget.watch")
local wibox = require("wibox")

local ramgraph_widget = {}

local function worker(user_args)
	local args = user_args or {}
	local timeout = args.timeout or 1
	local color_used = args.color_used or beautiful.bg_urgent
	local color_free = args.color_free or beautiful.fg_normal
	local color_buf = args.color_buf or beautiful.border_color_active
	local font = args.font or beautiful.font
	local widget_show_buf = args.widget_show_buf or false
	local widget_height = args.height or 25
	local widget_width = args.width or 25
	local recolor_icon = require("awesome-wm-widgets.recolor-icon")
	local colors = require("theme.mat-colors").color_palette
	local paddings = args.paddings or 4
	local word_spacing = args.word_spacing or 2

	local icon_widget = require("awesome-wm-widgets.icon-text-template.icon")({ size = widget_height })
	local level_widget = require("awesome-wm-widgets.icon-text-template.text")({ font = font })

	--luacheck:ignore 231
	local total, used, free, shared, buff_cache, available, total_swap, used_swap, free_swap

	local function getPercentage(value)
		return math.floor(value / (total + total_swap) * 100 + 0.5) .. "%"
	end

	local ram_split = function()
		return {
			{ "Used " .. getPercentage(used + used_swap), used + used_swap },
			{ "Free " .. getPercentage(free + free_swap), free + free_swap },
			{ "Buffer cache " .. getPercentage(buff_cache), buff_cache },
		}
	end

	--- Main ram widget shown on wibar
	ramgraph_widget.widget = wibox.widget({
		icon_widget,
		level_widget,
		forced_height = widget_height,
		forced_width = widget_width,
		spacing = word_spacing,
		paddings = paddings,
		layout = wibox.layout.fixed.horizontal,
		set_value = function(self, level)
			self:get_children_by_id("txt")[1]:set_text(level)
		end,
	})

	--- Widget which is shown when user clicks on the ram widget
	local popup = awful.popup({
		ontop = true,
		visible = false,
		widget = {
			widget = wibox.widget.piechart,
			forced_height = 180,
			forced_width = 336,
			colors = {
				color_used,
				color_free,
				color_buf, -- buf_cache
			},
		},
		shape = gears.shape.rounded_rect,
		border_color = beautiful.border_color_active,
		border_width = 2,
		offset = { y = 5 },
	})

	ramgraph_widget.widget:buttons(awful.util.table.join(awful.button({}, 1, function()
		popup:get_widget().data_list = ram_split()

		if popup.visible then
			popup.visible = not popup.visible
		else
			popup:move_next_to(mouse.current_widget_geometry)
		end
	end)))

	watch('bash -c "LANGUAGE=en_US.UTF-8 free | grep -z Mem.*Swap.*"', timeout, function(widget, stdout)
		total, used, free, shared, buff_cache, available, total_swap, used_swap, free_swap =
			stdout:match("(%d+)%s*(%d+)%s*(%d+)%s*(%d+)%s*(%d+)%s*(%d+)%s*Swap:%s*(%d+)%s*(%d+)%s*(%d+)")

		if widget_show_buf then
			widget.data = { used, free, buff_cache }
		else
			widget.data = { used, total - used }
		end

		if popup.visible then
			popup:get_widget().data_list = ram_split()
		end

		local round_1dp = function(n)
			return math.floor(n / 100000 + 0.5) / 10
		end

		widget:set_value(string.format("%02.1fGb", round_1dp(used)))
		local recolored_icon = recolor_icon("/theme/icons/ram.svg", colors.color_light)
		widget:get_children_by_id("icon")[1].image = recolored_icon
	end, ramgraph_widget.widget)

	return ramgraph_widget.widget
end

return setmetatable(ramgraph_widget, {
	__call = function(_, ...)
		return worker(...)
	end,
})
