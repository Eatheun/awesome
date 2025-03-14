local awful = require("awful")
local beautiful = require("beautiful")
local wibox = require("wibox")
local gears = require("gears")
local dpi = require("beautiful").xresources.apply_dpi
local mat_icon_button = require("layout.bars.stats-bar.volume-widget.material.icon-button")
local mat_icon = require("layout.bars.stats-bar.volume-widget.material.icon")
local icons = require("theme.icons")
local colors = require("theme.mat-colors").color_palette

-- Import widgets and bar items
-- Left pill
local TagList = require("layout.bars.tag-bar.tag-list")

-- Middle pill
local wifi_widget = require("layout.bars.middle-bar.wifi.init")
local time_widget = require("layout.bars.middle-bar.time-widget")
local layout_box = require("layout.bars.middle-bar.layout-box")

-- Right pill
local stats_widget_path = "layout.bars.stats-bar"
local cpu_widget = require(stats_widget_path .. ".cpu-widget.cpu-widget")
local ram_widget = require(stats_widget_path .. ".ram-widget.ram-widget")
local volume_widget = require(stats_widget_path .. ".volume-widget.volume")
local brightness_widget = require(stats_widget_path .. ".brightness-widget.brightness")
local battery_widget = require(stats_widget_path .. ".battery-widget.battery")

local add_button = mat_icon_button(mat_icon(icons.plus, dpi(32)))
add_button:buttons(gears.table.join(awful.button({}, 1, nil, function()
	awful.spawn(awful.screen.focused().selected_tag.defaultApp, {
		tag = _G.mouse.screen.selected_tag,
		placement = awful.placement.bottom_right,
	})
end)))

-- Concatenates two tables and returns
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

local pill_pad = 6 -- base padding on the inside of pill box
local extra_pad = pill_pad * 2
local base_size = 22 + pill_pad * 4
local panel_height = base_size * 5 / 4
local font_size = pill_pad * 1.75
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
				bg = colors.color_dark2,
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
	-- base_separator_props.text = "|"
	local style_text = "foreground='" .. colors.color_light .. "'"
	base_separator_props.markup = "<span " .. style_text .. " >|</span>"

	return wibox.widget(base_separator_props)
end

-- Here's the base arguments for the widgets
local base_table_args = {
	font = font,
	height = base_size,
	width = base_size * 1.55,
	type = "icon_and_text",
	word_spacing = pill_pad,
	main_color = colors.color_light,
	paddings = pill_pad,
}

-- Stats bar check for laptop or desktop
local extra_stats = {
	pill_separator(),
	brightness_widget(concat_table({
		program = "xbacklight",
		-- tooltip = true,
	}, base_table_args)),
	pill_separator(),
	battery_widget(concat_table({
		display_notification = true,
		enable_battery_warning = true,
		timeout = 5,
	}, base_table_args)),
}
-- awful.spawn.easy_async_with_shell("acpi -i", function(stdout)
-- 	if stdout == "No support for device type: power_supply" then
-- 		extra_stats = {}
-- 	end
-- end)

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

	panel:setup({
		layout = wibox.layout.align.horizontal,
		expand = "none",

		-- Tag pill
		pill_box(TagList(s)),

		-- Wifi, calendar and layout changer pill
		pill_box({
			layout = wibox.layout.fixed.horizontal,
			spacing = extra_pad,
			wifi_widget(base_table_args),
			pill_separator(),
			time_widget(pill_pad, font),
			pill_separator(),
			layout_box(s),
		}),

		-- Status pill
		pill_box({
			layout = wibox.layout.fixed.horizontal,
			spacing = extra_pad,

			-- Add all the imported widgets
			cpu_widget(concat_table({
				color = colors.color_light,
			}, base_table_args)),
			pill_separator(),
			ram_widget(concat_table({
				color_used = colors.color_dark,
				color_free = colors.color_med,
				color_buf = colors.color_light,
				widget_show_buf = true,
			}, base_table_args)),
			pill_separator(),
			volume_widget(concat_table({
				mute_color = colors.color_dark,
			}, base_table_args)),
			pill_separator(),
			brightness_widget(concat_table({
				program = "xbacklight",
				-- tooltip = true,
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
