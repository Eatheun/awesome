local wibox = require("wibox")
local dpi = require("beautiful").xresources.apply_dpi

local calendar_widget = require("layout.bars.middle-bar.calendar-widget.calendar")

local TimeWidget = function(pill_pad, font)
	local textclock = wibox.widget.textclock("<span font='" .. font .. "'>%I:%M %p</span>")
	local clock_widget = wibox.container.margin(textclock, dpi(pill_pad), dpi(pill_pad), dpi(pill_pad), dpi(pill_pad))

	-- or customized
	local cw = calendar_widget({
		placement = "top",
		start_sunday = true,
		radius = pill_pad * 4,
		previous_month_button = 3,
		next_month_button = 1,
		margin = pill_pad * 2,
	})
	textclock:connect_signal("button::press", function(_, _, _, button)
		if button == 1 then
			cw.toggle()
		end
	end)
	return clock_widget
end
return TimeWidget
