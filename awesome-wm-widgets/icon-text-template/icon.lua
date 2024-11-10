local wibox = require("wibox")
return function(args)
	return {
		{
			id = "icon",
			widget = wibox.widget.imagebox,
			resize = true,
			image = args.image or nil,
		},
		forced_height = args.size / 2.5,
		forced_width = args.size / 2.5,
		valign = "center",
		layout = wibox.container.place,
	}
end
