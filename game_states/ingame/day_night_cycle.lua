local night_shader_code = [[
		uniform float solar_position;
		uniform float screen_ratio;
		uniform float light_sources[60];
		uniform int light_source_array_length;

        vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {

        	vec4 pixelColorAtTexture = Texel(texture, texture_coords);
        	float length_to_center = (0.5 - texture_coords[0]) * (0.5 - texture_coords[0]) * screen_ratio + (0.5 - texture_coords[1]) * (0.5 - texture_coords[1]);

        	length_to_center = pow(length_to_center, 0.5); 

        	float gray_scale = (pixelColorAtTexture[0] + pixelColorAtTexture[1] + pixelColorAtTexture[2])/3;

            vec3 gray_scaled_color = vec3(
            mix(gray_scale, pixelColorAtTexture[0], 0.5+solar_position/2), 
            mix(gray_scale, pixelColorAtTexture[1], 0.5+solar_position/2), 
            mix(gray_scale, pixelColorAtTexture[2], 0.5+solar_position/2)); //mixes a color with a gray scaled color

            float light_from_aura = clamp((0.3/length_to_center)*(0.05+3.0*solar_position/4), 0, 0.5); //this is same for all three colours 

            float red_light_from_sources = 0;
            float green_light_from_sources = 0;
            float blue_light_from_sources = 0;

			for (int i = 0; i < 60; i+=6) {
  				if (i >= light_source_array_length) break;
  				
  				float dist_lightsource = (light_sources[i] - texture_coords[0]) * (light_sources[i] - texture_coords[0]) * screen_ratio + 
  				(light_sources[i+1] - texture_coords[1]) * (light_sources[i+1] - texture_coords[1]);

  				dist_lightsource = pow(dist_lightsource, 0.5);

  				float strength = light_sources[i+5];

  				red_light_from_sources += light_sources[i+5]*light_sources[i+2]/dist_lightsource;
  				green_light_from_sources += light_sources[i+5]*light_sources[i+3]/dist_lightsource;
  				blue_light_from_sources += light_sources[i+5]*light_sources[i+4]/dist_lightsource;
			}

        	vec3 light_rgb = vec3(
				clamp(light_from_aura + solar_position + red_light_from_sources, 0, 1),
				clamp(light_from_aura + solar_position + green_light_from_sources, 0, 1),
				clamp(light_from_aura + solar_position + blue_light_from_sources, 0, 1)
        	);
            
            vec3 pixel_color = gray_scaled_color*light_rgb;

            return vec4(pixel_color, 1.0);
        }
	]]

local day_night_cycle = {
	seconds_per_day = 600,
	clock_hours = 24,
	info_share = require "info_share",
	day_night_shader = love.graphics.newShader(night_shader_code),
	d_p_c = require "game_states.ingame.draw_position_calculator"
}

local function get_solar_position(clock)
	return 0.5 + math.cos(math.pi+math.pi*2*clock)/2
end

local function get_normalised_light_array()
	local lights = day_night_cycle.info_share.get_game_info("light_sources")()
	local detective_position = day_night_cycle.info_share.get_game_info("detective_position")()
	local lights_normalised = {}
	local d_p_c = day_night_cycle.d_p_c

	for index,light in ipairs(lights) do
		local light_position = light.position()
		local colour = light.colour()
		lights_normalised[6*index-5] = d_p_c.square_size*(light_position.x-detective_position.x)/window_initial_width+0.5 --This calculates the position of the light source relative to the detective
		lights_normalised[6*index-4] = d_p_c.square_size*(light_position.y-detective_position.y)/window_initial_height+0.5 --And then the light relative to the start of the screen. 0.5 says that the light is in the center of the screen if it is at the same position as the detective 
		lights_normalised[6*index-3] = colour.red
		lights_normalised[6*index-2] = colour.green
		lights_normalised[6*index-1] = colour.blue
		lights_normalised[6*index-0] = light.strength() 
	end
	return lights_normalised
end

local function draw_with_night_shader(canvas_to_draw, clock)
	local light_sources = get_normalised_light_array()

	day_night_cycle.day_night_shader:send("light_sources", unpack(light_sources))
	day_night_cycle.day_night_shader:send("light_source_array_length", #light_sources)
	day_night_cycle.day_night_shader:send("solar_position", get_solar_position(clock))
	day_night_cycle.day_night_shader:send("screen_ratio", (window_initial_width/window_initial_height)^2)
	love.graphics.setShader(day_night_cycle.day_night_shader)
	love.graphics.draw(canvas_to_draw)
	love.graphics.setShader()
end

local function draw_with_light_setting_simple(canvas_to_draw, clock)
	local prev_red, prev_green, prev_blue, prev_alpha = love.graphics.getColor()
	local solar_position = get_solar_position(clock)

	love.graphics.setColor(0.3+0.7*solar_position, 0.3+0.7*solar_position, 0.4+0.6*solar_position)
	love.graphics.draw(canvas_to_draw)
	love.graphics.setColor(prev_red, prev_green, prev_blue, prev_alpha)
end

function day_night_cycle.get_return_object(graphics_mode)
	graphics_mode = graphics_mode or "simple"
	local clock = 15/day_night_cycle.clock_hours

	return {
		tick = function (delta_time)
			clock = clock + delta_time / day_night_cycle.seconds_per_day
			day_night_cycle.info_share.register_game_info("clock", function() return (clock%1)*day_night_cycle.clock_hours end)
		end,
		draw_with_light_setting = function(canvas_to_draw)
			if graphics_mode == "simple" then
				draw_with_light_setting_simple(canvas_to_draw, clock)
			else
				draw_with_night_shader(canvas_to_draw, clock)
			end
		end
	}
end

return day_night_cycle
