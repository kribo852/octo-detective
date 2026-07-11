local day_night_cycle = {
	seconds_per_day = 600,
	clock_hours = 24
}

function day_night_cycle.get_return_object(graphics_mode)
	graphics_mode = graphics_mode or "simple"
	local clock = 15/day_night_cycle.clock_hours

	local get_darkness_level_color = function()
		return (1-0.4)+0.4*math.cos(math.pi+math.pi*2*clock),
			   (1-0.3)+0.3*math.cos(math.pi+math.pi*2*clock),
			   (1-0.2)+0.2*math.cos(math.pi+math.pi*2*clock)
	end

	local function draw_with_light_setting_simple(canvas_to_draw, light_sources)
		local prev_red, prev_green, prev_blue, prev_alpha = love.graphics.getColor()

		love.graphics.setColor(get_darkness_level_color())
		love.graphics.draw(canvas_to_draw)
		love.graphics.setColor(prev_red, prev_green, prev_blue, prev_alpha)
	end

	return {
		get_clock = function() return day_night_cycle.clock_hours*(clock%1) end,
		tick = function (delta_time)
			clock = clock + delta_time / day_night_cycle.seconds_per_day
		end,

		draw_with_light_setting = draw_with_light_setting_simple
	}
end

return day_night_cycle
