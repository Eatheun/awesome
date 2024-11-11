local awful = require("awful")
local apps = require("configuration.apps")

local tags = {
	{
		type = "code",
		defaultApp = apps.default.editor,
		screen = 1,
	},
	{
		type = "chrome",
		defaultApp = apps.default.browser,
		screen = 1,
	},
	{
		type = "social",
		defaultApp = apps.default.social,
		screen = 1,
	},
	{
		type = "any",
		defaultApp = apps.default.rofi,
		screen = 1,
	},
	-- Add more tags here
}

awful.layout.layouts = {
	awful.layout.suit.corner.nw,
	awful.layout.suit.tile.right,
	awful.layout.suit.tile.bottom,
	awful.layout.suit.max,
	awful.layout.suit.floating,
}

awful.screen.connect_for_each_screen(function(s)
	for i, tag in pairs(tags) do
		awful.tag.add(i, {
			icon = tag.icon,
			icon_only = true,
			layout = awful.layout.suit.tile,
			gap_single_client = false,
			gap = 8,
			screen = s,
			defaultApp = tag.defaultApp,
			selected = i == 1, -- sets focus to tag #1 on startup
		})
	end
end)

_G.tag.connect_signal("property::layout", function(t)
	local currentLayout = awful.tag.getproperty(t, "layout")
	if currentLayout == awful.layout.suit.max then
		t.gap = 0
	else
		t.gap = 8
	end
end)
