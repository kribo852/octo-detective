local day_night_cycle = {}


function day_night_cycle.get_return_object(graphics_mode)
	graphics_mode = graphics_mode or "simple"
	local clock = 15/24;

	local get_darkness_level_color = function()
		return 0, 0.025, 0.05, 0.28*(1+math.cos(math.pi*2*clock))
	end

	return {
		get_clock = function() return 24*(clock%1) end,
		tick = function (delta_time)
			clock = clock + delta_time / 600
		end,

		paint_light_setting = function ()
			local prev_red, prev_green, prev_blue, prev_alpha = love.graphics.getColor()
			local new_red, new_green, new_blue, new_alpha = get_darkness_level_color()

			love.graphics.setColor(new_red, new_green, new_blue, new_alpha)

			love.graphics.rectangle("fill", 0, 0, window_initial_width, window_initial_height)

			love.graphics.setColor(prev_red, prev_green, prev_blue, prev_alpha)
		end

	}
end


return day_night_cycle