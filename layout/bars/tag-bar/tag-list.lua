local awful = require("awful")
local wibox = require("wibox")
local dpi = require("beautiful").xresources.apply_dpi
local gears = require("gears")
local gfs = gears.filesystem
local modkey = require("keys.mod").modKey
local colors = require("theme.mat-colors").color_palette

local margin = 7

local TagList = function(s)
	-- Taglist buttons for clicking on tags
	local taglist_buttons = gears.table.join(
		awful.button({}, 1, function(t)
			t:view_only()
		end),
		awful.button({ modkey }, 1, function(t)
			if client.focus then
				client.focus:move_to_tag(t)
			end
		end),
		awful.button({}, 3, awful.tag.viewtoggle),
		awful.button({ modkey }, 3, function(t)
			if client.focus then
				client.focus:toggle_tag(t)
			end
		end),
		awful.button({}, 4, function(t)
			awful.tag.viewnext(t.screen)
		end),
		awful.button({}, 5, function(t)
			awful.tag.viewprev(t.screen)
		end)
	)

	----------------------------------------------------------------------
	----------------------------------------------------------------------

	local base_icon_path = gfs.get_configuration_dir() .. "layout/bars/tag-bar/tag-icons/"
	local empty = gears.surface.load_uncached(base_icon_path .. "shii.png")
	local empty_icon = gears.color.recolor_image(empty, colors.color_dark)
	local unfocus = gears.surface.load_uncached(base_icon_path .. "gutsu.png")
	local unfocus_icon = gears.color.recolor_image(unfocus, colors.color_med)
	local focus = gears.surface.load_uncached(base_icon_path .. "haku.png")
	local focus_icon = gears.color.recolor_image(focus, colors.color_light)

	----------------------------------------------------------------------
	----------------------------------------------------------------------

	-- Function to update the tags
	local update_tags = function(self, c3)
		local tagicon = self:get_children_by_id("icon_role")[1]
		if c3.selected then
			tagicon.image = focus_icon
		elseif #c3:clients() == 0 then
			tagicon.image = empty_icon
		else
			tagicon.image = unfocus_icon
		end
	end

	----------------------------------------------------------------------
	----------------------------------------------------------------------

	return awful.widget.taglist({
		screen = s,
		filter = awful.widget.taglist.filter.all,
		layout = { spacing = 0, layout = wibox.layout.fixed.horizontal },
		widget_template = {
			{
				{
					id = "icon_role",
					widget = wibox.widget.imagebox,
				},
				shape = function(cr, w, h)
					gears.shape.rounded_bar(cr, w, h)
				end,
				id = "margin_role",
				top = dpi(margin),
				bottom = dpi(margin),
				left = dpi(margin),
				right = dpi(margin),
				widget = wibox.container.margin,
			},
			id = "background_role",
			widget = wibox.container.background,
			create_callback = function(self, c3, index, objects)
				update_tags(self, c3)
			end,

			update_callback = function(self, c3, index, objects)
				update_tags(self, c3)
			end,
		},
		-- buttons = taglist_buttons,
	})
end
return TagList
