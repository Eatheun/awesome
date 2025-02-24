local filesystem = require("gears.filesystem")
local mat_colors = require("theme.mat-colors")
local colors = mat_colors.color_palette
local theme_dir = filesystem.get_configuration_dir() .. "/theme"
local gears = require("gears")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local recolor_icon = require("awesome-wm-widgets.recolor-icon")

local theme = {}
theme.icons = theme_dir .. "/icons/"
theme.font = "Roboto medium 10"

-- Colors Pallets

-- Primary
theme.primary = mat_colors.deep_orange

-- Accent
theme.accent = mat_colors.pink

-- Background
theme.background = mat_colors.grey

-- My color palette
theme.color_palette = mat_colors.color_palette

local awesome_overrides = function(theme)
	theme.dir = os.getenv("HOME") .. "/.config/awesome/theme"
	theme.layout_icons_rel_dir = "/theme/icons/layout-icons/"
	--theme.wallpaper = theme.dir .. '/wallpapers/DarkCyan.png'
	theme.wallpaper = "#e0e0e0"
	theme.font = "Roboto medium 10"
	theme.title_font = "Roboto medium 14"

	theme.fg_normal = theme.color_palette.color_med --"#ffffffde"

	theme.fg_focus = "#e4e4e4"
	theme.fg_urgent = "#CC9393"
	theme.bat_fg_critical = "#232323"

	theme.bg_normal = theme.color_palette.color_dark2 -- theme.background.hue_800
	theme.bg_focus = theme.color_palette.color_dark2
	theme.bg_urgent = "#3F3F3F"
	theme.bg_systray = theme.background.hue_800

	-- Borders
	theme.border_width = dpi(2)
	theme.border_normal = theme.background.hue_800
	theme.border_focus = theme.primary.hue_300
	theme.border_marked = "#CC9393"
	-- Menu
	theme.menu_height = dpi(42)
	theme.menu_width = dpi(180)

	-- Tooltips
	theme.tooltip_bg = theme.color_palette.color_dark2
	--theme.tooltip_border_color = '#232323'
	-- theme.tooltip_border_width = 4
	theme.tooltip_shape = function(cr, w, h)
		gears.shape.rounded_rect(cr, w, h, dpi(12))
	end

	-- Layout
	theme.layout_cornernw = recolor_icon(theme.layout_icons_rel_dir .. "jera.png", colors.color_dark)
	theme.layout_tile = recolor_icon(theme.layout_icons_rel_dir .. "perthro.png", colors.color_dark)
	theme.layout_max = recolor_icon(theme.layout_icons_rel_dir .. "algiz.png", colors.color_dark)
	theme.layout_floating = recolor_icon(theme.layout_icons_rel_dir .. "berkano.png", colors.color_dark)

	-- Taglist
	theme.taglist_bg_empty = theme.color_palette.color_dark2
	theme.taglist_bg_occupied = theme.color_palette.color_dark2
	theme.taglist_bg_urgent = "linear:0,0:"
		.. dpi(40)
		.. ",0:0,"
		.. theme.accent.hue_500
		.. ":0.08,"
		.. theme.accent.hue_500
		.. ":0.08,"
		.. theme.background.hue_800
		.. ":1,"
		.. theme.background.hue_800

	-- Tasklist
	theme.tasklist_font = "Roboto medium 11"
	theme.tasklist_bg_normal = theme.background.hue_800
	theme.tasklist_bg_focus = "linear:0,0:0,"
		.. dpi(40)
		.. ":0,"
		.. theme.background.hue_800
		.. ":0.95,"
		.. theme.background.hue_800
		.. ":0.95,"
		.. theme.fg_normal
		.. ":1,"
		.. theme.fg_normal
	theme.tasklist_bg_urgent = theme.primary.hue_800
	theme.tasklist_fg_focus = "#DDDDDD"
	theme.tasklist_fg_urgent = theme.fg_normal
	theme.tasklist_fg_normal = "#AAAAAA"

	theme.icon_theme = "Papirus-Dark"

	--Client ("" to disable colour)
	theme.border_width = dpi(0)
	theme.border_focus = "" -- theme.primary.hue_100
	theme.border_normal = "" -- theme.background.hue_700
end
return {
	theme = theme,
	awesome_overrides = awesome_overrides,
}
