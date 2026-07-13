local water_effect = {
	ticker = 0
}

 -- Ladda shadern
    local shaderCode = [[
        uniform float ticker;
        uniform int start_x;
        uniform int start_y;

        vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
            float o_x = screen_coords[0] - start_x;
			float o_y = screen_coords[1] - start_y;

            float randomValue = mod(43 + o_x*o_y*23 + o_x*13 + o_y*97 + ticker, 250)/250;

            /*if(randomValue >= 125) {
            	randomValue = 1.0;
            } else {
            	randomValue = 0.0;
            }*/

            // Skapa en färg (RGB) med det slumpmässiga värdet
            vec4 pixelColor = vec4(
                0.1+0.05*(1.0-randomValue),  // R
                clamp(0.2+0.15*randomValue + screen_coords[1]*0.0001 , 0, 1),  // G
                clamp(0.2+0.25*randomValue + screen_coords[1]*0.0001 , 0, 1),  // B
                1 // A (full opacity)
            );

            return pixelColor;
        }
    ]]

    local shader2 = [[
        uniform float ticker;
        uniform int start_x;
        uniform int start_y;

        float random(float n) {
            return fract(sin(n) * 43758.5453);
        }

        vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
            float o_x = screen_coords[0] - start_x;
            float o_y = screen_coords[1] - start_y;

            float randomValue_x = 24*random(o_x)-12; 
            float randomValue_y = 24*random(o_y)-12;
            float sinef_a = sin((ticker + o_x + o_y + randomValue_x + randomValue_y)/7);
            float sinef_b = sin((ticker + o_x + o_y + randomValue_x + randomValue_y)/7 + 3.14/3);
            float sinef_c = sin((ticker + o_x + o_y + randomValue_x + randomValue_y)/7 + 6.28/3);

            vec4 pixelColor = vec4(
                0.45 + 0.0325*sinef_a, // R
                0.35 + 0.0325*sinef_b, // G
                0.30 + 0.0325*sinef_c, // B
                1 // A (full opacity)
            );

            return pixelColor;
        }
    ]]

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
                mix(0.35, pixelColorAtTexture[0], 0.4 + 0.1 * (sinef_a+sinef_b+sinef_c) ), // R
                mix(0.45, pixelColorAtTexture[1], 0.4 + 0.1 * (sinef_a+sinef_b+sinef_c) ), // G
                mix(0.40, pixelColorAtTexture[2], 0.4 + 0.1 * (sinef_a+sinef_b+sinef_c) ), // B
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
