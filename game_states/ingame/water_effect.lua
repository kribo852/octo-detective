local water_effect = {
	ticker = 0
}

local shader3 = [[
    #define PI 3.1415926538
    uniform float ticker;
    uniform int start_x;
    uniform int start_y;

    vec2 get_random(float ticker, float x, float y) {
        return vec2(0.01*sin(PI/1.6*(ticker+x)), 0.01*cos(PI/1.6*(ticker+y)));
    }

    vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {

        float o_x = 3.14*(screen_coords[0] - start_x)/30;
        float o_y = 3.14*(screen_coords[1] - start_y)/30;

        float sinef_a = sin((ticker + o_x + o_y));
        float sinef_b = 0.5*sin((ticker - o_x + o_y)*5);
        float sinef_c = 0.5*sin((ticker + o_x - o_y*3));

        vec4 pixelColorAtTexture = Texel(texture, texture_coords+get_random(ticker, texture_coords.x, texture_coords.y));

        vec4 pixelColor = vec4(
            mix(0.035, pixelColorAtTexture[0], 0.2 + 0.1 * (sinef_a) ), // R
            mix(0.1, pixelColorAtTexture[1], 0.2 + 0.1 * (sinef_b) ), // G
            mix(0.075, pixelColorAtTexture[2], 0.2 + 0.1 * (sinef_c) ), // B
            1 // A (full opacity)
        );

        return pixelColor;
    }
]]

function water_effect.make_water_effect(start_x, start_y, end_x, end_y, scale)
	water_effect.ticker = water_effect.ticker + 1
	water_effect.shader:send("ticker", water_effect.ticker / 750)
    water_effect.shader:send("start_x", start_x)
    water_effect.shader:send("start_y", start_y)

	love.graphics.setShader(water_effect.shader)
	love.graphics.draw(water_effect.background_image, start_x, start_y, 0, scale or 3)
	love.graphics.setShader()
end

function water_effect.load()

	water_effect.shader = love.graphics.newShader(shader3)
	water_effect.background_image = love.graphics.newImage("assets/river_bottom.png")
end

return water_effect
