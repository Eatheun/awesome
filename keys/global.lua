local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
local hotkeys_popup = require("awful.hotkeys_popup").widget

local modkey = require("keys.mod").modKey
local altkey = require("keys.mod").altKey
local apps = require("configuration.apps")

local terminal = "x-terminal-emulator"
editor = os.getenv("EDITOR") or "editor"
editor_cmd = terminal .. " -e " .. editor
local mymainmenu = require("configuration.client.default_menu")

local volume_widget = require("layout.bars.stats-bar.volume-widget.volume")
local brightness_widget = require("layout.bars.stats-bar.brightness-widget.brightness")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
	naughty.notify({
		preset = naughty.config.presets.critical,
		title = "Oops, there were errors during startup!",
		text = awesome.startup_errors,
	})
end
-- }}}

-- {{{ Mouse bindings
root.buttons(gears.table.join(
	awful.button({}, 3, function()
		mymainmenu:toggle()
	end),
	awful.button({}, 4, awful.tag.viewnext),
	awful.button({}, 5, awful.tag.viewprev)
))
-- }}}

-- Setting icons
local icons = require("theme.icons")

-- Key bindings
local globalKeys = awful.util.table.join(
	-- Hotkeys
	awful.key({ modkey }, "F1", hotkeys_popup.show_help, { description = "Show help", group = "awesome" }),

	-- Terminal
	awful.key({ modkey }, "Return", function()
		awful.spawn(terminal)
	end, { description = "open a terminal", group = "launcher" }),

	-- Default menu open up
	awful.key({ modkey }, "w", function()
		mymainmenu:show()
	end, { description = "Show default menu", group = "awesome" }),

	-- Tag browsing
	awful.key({ modkey }, "h", awful.tag.viewprev, { description = "view previous", group = "tag" }),
	awful.key({ modkey }, "l", awful.tag.viewnext, { description = "view next", group = "tag" }),

	-- Default client focus
	awful.key({ modkey }, "d", function()
		awful.client.focus.byidx(1)
	end, { description = "Focus next by index", group = "client" }),
	awful.key({ modkey }, "a", function()
		awful.client.focus.byidx(-1)
	end, { description = "Focus previous by index", group = "client" }),
	awful.key({ modkey }, "r", function()
		awful.spawn("rofi -combi-modi window,drun -show combi -modi combi")
	end, { description = "Main menu", group = "awesome" }),
	awful.key({ altkey }, "space", function()
		awful.spawn("rofi -combi-modi window,drun -show combi -modi combi")
	end, { description = "Show main menu", group = "awesome" }),
	awful.key({ modkey, "Shift" }, "r", function()
		awful.spawn("reboot")
	end, { description = "Reboot Computer", group = "awesome" }),

	-- Power/Lock/Suspend
	awful.key({ modkey, "Shift" }, "s", function()
		awful.spawn("shutdown now")
	end, { description = "Shutdown Computer", group = "awesome" }),
	awful.key({ modkey }, "Escape", function()
		_G.exit_screen_show()
	end, { description = "Log Out Screen", group = "awesome" }),

	-- Tabs? idk
	awful.key({ modkey }, "u", awful.client.urgent.jumpto, { description = "jump to urgent client", group = "client" }),
	awful.key({ altkey }, "Tab", function()
		--awful.client.focus.history.previous()
		awful.client.focus.byidx(1)
		if _G.client.focus then
			_G.client.focus:raise()
		end
	end, { description = "Switch to next window", group = "client" }),
	awful.key({ altkey, "Shift" }, "Tab", function()
		--awful.client.focus.history.previous()
		awful.client.focus.byidx(-1)
		if _G.client.focus then
			_G.client.focus:raise()
		end
	end, { description = "Switch to previous window", group = "client" }),

	-- Screenshotting
	awful.key({ modkey }, "Print", function()
		awful.util.spawn_with_shell(apps.default.delayed_screenshot)
	end, {
		description = "Mark an area and screenshot it 10 seconds later (clipboard)",
		group = "screenshots (clipboard)",
	}),
	awful.key({ modkey }, "p", function()
		awful.util.spawn_with_shell(apps.default.region_screenshot)
	end, { description = "Mark an area and screenshot it to your clipboard", group = "screenshots (clipboard)" }),
	awful.key({ altkey, "Shift" }, "p", function()
		awful.util.spawn_with_shell(apps.default.screenshot)
	end, {
		description = "Take a screenshot of your active monitor and copy it to clipboard",
		group = "screenshots (clipboard)",
	}),

	awful.key({ modkey }, "c", function()
		awful.util.spawn(apps.default.editor)
	end, { description = "Open a text/code editor", group = "launcher" }),
	awful.key({ modkey }, "b", function()
		awful.util.spawn(apps.default.browser)
	end, { description = "Open a browser", group = "launcher" }),

	-- Standard program
	awful.key({ modkey, "Control" }, "r", _G.awesome.restart, { description = "reload awesome", group = "awesome" }),
	awful.key({ modkey, "Control" }, "q", _G.awesome.quit, { description = "quit awesome", group = "awesome" }),

	-- Changing window dims
	awful.key({ altkey, "Shift" }, "l", function()
		awful.tag.incmwfact(0.05)
	end, { description = "Increase master width factor", group = "layout" }),
	awful.key({ altkey, "Shift" }, "h", function()
		awful.tag.incmwfact(-0.05)
	end, { description = "Decrease master width factor", group = "layout" }),
	awful.key({ altkey, "Shift" }, "j", function()
		awful.client.incwfact(0.05)
	end, { description = "Decrease master height factor", group = "layout" }),
	awful.key({ altkey, "Shift" }, "k", function()
		awful.client.incwfact(-0.05)
	end, { description = "Increase master height factor", group = "layout" }),

	awful.key({ modkey, "Shift" }, "Left", function()
		awful.tag.incnmaster(1, nil, true)
	end, { description = "Increase the number of master clients", group = "layout" }),
	awful.key({ modkey, "Shift" }, "Right", function()
		awful.tag.incnmaster(-1, nil, true)
	end, { description = "Decrease the number of master clients", group = "layout" }),
	awful.key({ modkey, "Control" }, "Left", function()
		awful.tag.incncol(1, nil, true)
	end, { description = "Increase the number of columns", group = "layout" }),
	awful.key({ modkey, "Control" }, "Right", function()
		awful.tag.incncol(-1, nil, true)
	end, { description = "Decrease the number of columns", group = "layout" }),
	awful.key({ modkey }, "space", function()
		awful.layout.inc(1)
	end, { description = "Select next", group = "layout" }),
	awful.key({ modkey, "Shift" }, "space", function()
		awful.layout.inc(-1)
	end, { description = "Select previous", group = "layout" }),
	awful.key({ modkey, "Control" }, "n", function()
		local c = awful.client.restore()
		-- Focus restored client
		if c then
			_G.client.focus = c
			c:raise()
		end
	end, { description = "restore minimized", group = "client" }),

	-- Brightness
	-- "XF86MonBrightnessUp"
	awful.key({}, "F7", function()
		brightness_widget:inc()
	end, { description = "+5%", group = "hotkeys" }),
	-- "XF86MonBrightnessDown"
	awful.key({}, "F6", function()
		brightness_widget:dec()
	end, { description = "-5%", group = "hotkeys" }),

	-- ALSA volume control
	-- "XF86AudioRaiseVolume"
	awful.key({}, "F3", function()
		volume_widget:inc(5)
	end, { description = "Volume up 5%", group = "hotkeys" }),
	-- "XF86AudioLowerVolume"
	awful.key({}, "F2", function()
		volume_widget:dec(5)
	end, { description = "Volume down 5%", group = "hotkeys" }),
	-- "XF86AudioMute"
	awful.key({}, "F1", function()
		volume_widget:toggle()
	end, { description = "Toggle mute", group = "hotkeys" }),

	-- Exit screen
	awful.key({}, "XF86PowerOff", function()
		_G.exit_screen_show()
	end, { description = "Show exit screen", group = "hotkeys" }),

	-- Screen management
	awful.key(
		{ modkey },
		"o",
		awful.client.movetoscreen,
		{ description = "move window to next screen", group = "client" }
	),

	-- Open default program for tag
	awful.key({ modkey }, "t", function()
		awful.spawn(awful.screen.focused().selected_tag.defaultApp, {
			tag = _G.mouse.screen.selected_tag,
			placement = awful.placement.bottom_right,
		})
	end, { description = "Open default program for tag/workspace", group = "tag" }),

	-- Custom hotkeys
	-- vfio integration
	awful.key({ "Control", altkey }, "space", function()
		awful.util.spawn_with_shell("vm-attach attach")
	end),
	-- Lutris hotkey
	awful.key({ modkey }, "g", function()
		awful.util.spawn_with_shell("lutris")
	end),
	-- System Monitor hotkey
	awful.key({ modkey }, "m", function()
		awful.util.spawn_with_shell("mate-system-monitor")
	end),
	-- Kill VLC
	awful.key({ modkey }, "v", function()
		awful.util.spawn_with_shell("killall -9 vlc")
	end),
	-- File Manager
	awful.key({ modkey }, "e", function()
		awful.util.spawn(apps.default.files)
	end, { description = "filebrowser", group = "hotkeys" }),
	-- Emoji Picker
	awful.key({ modkey, "Control" }, "i", function()
		awful.util.spawn_with_shell("ibus emoji")
	end, { description = "Open the ibus emoji picker to copy an emoji to your clipboard", group = "hotkeys" })
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
	-- Hack to only show tags 1 and 9 in the shortcut window (mod+s)
	local descr_view, descr_toggle, descr_move, descr_toggle_focus
	if i == 1 or i == 9 then
		descr_view = { description = "view tag #", group = "tag" }
		descr_toggle = { description = "toggle tag #", group = "tag" }
		descr_move = { description = "move focused client to tag #", group = "tag" }
		descr_toggle_focus = { description = "toggle focused client on tag #", group = "tag" }
	end
	globalKeys = awful.util.table.join(
		globalKeys,
		-- View tag only.
		awful.key({ modkey }, "#" .. i + 9, function()
			local screen = awful.screen.focused()
			local tag = screen.tags[i]
			if tag then
				tag:view_only()
			end
		end, descr_view),
		-- Toggle tag display.
		awful.key({ modkey, "Control" }, "#" .. i + 9, function()
			local screen = awful.screen.focused()
			local tag = screen.tags[i]
			if tag then
				awful.tag.viewtoggle(tag)
			end
		end, descr_toggle),
		-- Move client to tag.
		awful.key({ modkey, "Shift" }, "#" .. i + 9, function()
			if _G.client.focus then
				local tag = _G.client.focus.screen.tags[i]
				if tag then
					_G.client.focus:move_to_tag(tag)
				end
			end
		end, descr_move),
		-- Toggle tag on focused client.
		awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9, function()
			if _G.client.focus then
				local tag = _G.client.focus.screen.tags[i]
				if tag then
					_G.client.focus:toggle_tag(tag)
				end
			end
		end, descr_toggle_focus)
	)
end

return globalKeys
