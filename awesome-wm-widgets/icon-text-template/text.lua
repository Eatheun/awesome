local wibox = require("wibox")
return function(args)
	return {
		id = "txt",
		font = args.font,
		widget = wibox.widget.textbox,
	}
end
