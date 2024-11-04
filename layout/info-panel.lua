local awful = require("awful")
local beautiful = require("beautiful")
local wibox = require("wibox")
local TagList = require("widget.tag-list")
local gears = require("gears")
local dpi = require("beautiful").xresources.apply_dpi
local clickable_container = require("widget.material.clickable-container")
local mat_icon_button = require("widget.material.icon-button")
local mat_icon = require("widget.material.icon")
local icons = require("theme.icons")

-- Import widgets
local wifi_widget = require("widget.wifi")
local cpu_widget = require("awesome-wm-widgets.cpu-widget.cpu-widget")
local ram_widget = require("awesome-wm-widgets.ram-widget.ram-widget")
local volume_widget = require("awesome-wm-widgets.volume-widget.volume")
local brightness_widget = require("awesome-wm-widgets.brightness-widget.brightness")
local battery_widget = require("awesome-wm-widgets.battery-widget.battery")

local add_button = mat_icon_button(mat_icon(icons.plus, dpi(32)))
add_button:buttons(gears.table.join(awful.button({}, 1, nil, function()
	awful.spawn(awful.screen.focused().selected_tag.defaultApp, {
		tag = _G.mouse.screen.selected_tag,
		placement = awful.placement.bottom_right,
	})
end)))

-- Create an imagebox widget which will contains an icon indicating which layout we're using.
-- We need one layoutbox per screen.
local LayoutBox = function(s)
	local layoutBox = clickable_container(awful.widget.layoutbox(s), dpi(4), dpi(4), dpi(8), dpi(4))
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

local pill_pad = 6 -- base padding on the inside of pill box
local extra_pad = pill_pad * 2
local base_size = 22 + pill_pad * 4
local panel_height = base_size * 5 / 4
local color_light = "#ffdede"
local color_med = "#9a6868"
local color_dark = "#4a312f"
local color_dark2 = "#183057"
local font_size = pill_pad * 2
local font = "Ubuntu Bold " .. font_size

-- Pill container around widgets
local pill_box = function(widget)
	-- Outer margin for offsetting from screen
	-- Inner margin for the actual pill
	return wibox.container.margin(
		wibox.widget({
			layout = wibox.layout.fixed.horizontal,
			{
				wibox.container.margin(
					wibox.widget({
						layout = wibox.layout.fixed.horizontal,
						widget,
					}),
					dpi(pill_pad * 4),
					dpi(pill_pad * 4),
					dpi(pill_pad),
					dpi(pill_pad)
				),
				bg = color_dark2,
				shape = function(cr, w, h)
					gears.shape.rounded_bar(cr, w, h)
				end,
				widget = wibox.container.background,
			},
		}),
		dpi(extra_pad),
		dpi(extra_pad),
		dpi(extra_pad)
	)
end

-- Separator between pill box elements
local pill_separator = function()
	local base_separator_props = require("awesome-wm-widgets.icon-text-template.text")({ font = font })
	base_separator_props.text = "|"
	return wibox.widget(base_separator_props)
end

local textclock = wibox.widget.textclock("<span font='" .. font .. "'>%I:%M %p</span>")
-- Add a calendar (credits to kylekewley for the original code)
local month_calendar = awful.widget.calendar_popup.month({
	screen = s,
	start_sunday = true,
	week_numbers = true,
})
month_calendar:attach(textclock)
local clock_widget = wibox.container.margin(textclock, dpi(pill_pad), dpi(pill_pad), dpi(pill_pad), dpi(pill_pad))

local InfoPanel = function(s)
	local panel = wibox({
		ontop = false,
		screen = s,
		height = dpi(panel_height),
		width = s.geometry.width,
		x = s.geometry.x,
		y = s.geometry.y,
		stretch = false,
		bg = "",
		fg = beautiful.fg_normal,
		opacity = 1,
		struts = {
			top = dpi(panel_height),
		},
	})

	panel:struts({
		top = dpi(panel_height),
	})

	-- Here's the base arguments for the widgets
	local base_table_args = {
		font = font,
		height = base_size,
		width = base_size * 1.55,
		type = "icon_and_text",
		word_spacing = pill_pad,
		main_color = color_light,
	}
	local concat_table = function(t1, t2)
		local t3 = {}
		for k, v in pairs(t1) do
			t3[k] = v
		end
		for k, v in pairs(t2) do
			t3[k] = v
		end
		return t3
	end

	panel:setup({
		layout = wibox.layout.align.horizontal,
		expand = "none",

		-- Tag pill
		pill_box(TagList(s)),

		-- Wifi, calendar and layout changer pill
		pill_box({
			layout = wibox.layout.fixed.horizontal,
			spacing = extra_pad,
			wifi_widget,
			pill_separator(),
			clock_widget,
			pill_separator(),
			LayoutBox(s),
		}),

		-- Status pill
		pill_box({
			layout = wibox.layout.fixed.horizontal,
			spacing = extra_pad,

			-- Add all the imported widgets
			cpu_widget(concat_table({
				color = color_light,
				paddings = pill_pad,
			}, base_table_args)),
			pill_separator(),
			ram_widget(concat_table({
				color_used = color_dark,
				color_free = color_light,
				color_buf = color_med,
				widget_show_buf = true,
			}, base_table_args)),
			pill_separator(),
			volume_widget(concat_table({
				mute_color = color_dark,
			}, base_table_args)),
			pill_separator(),
			brightness_widget(concat_table({
				program = "xbacklight",
				tooltip = true,
			}, base_table_args)),
			pill_separator(),
			battery_widget(concat_table({
				display_notification = true,
				enable_battery_warning = true,
				timeout = 5,
			}, base_table_args)),
		}),
	})

	return panel
end

return InfoPanel