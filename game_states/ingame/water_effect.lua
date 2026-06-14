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

function water_effect.make_water_effect(start_x, start_y, end_x, end_y)
	water_effect.ticker = water_effect.ticker + 1
	water_effect.shader:send("start_x", start_x)
	water_effect.shader:send("start_y", start_y)
	water_effect.shader:send("ticker", math.floor(water_effect.ticker / 50))
	love.graphics.setShader(water_effect.shader)
	love.graphics.draw(water_effect.background_image, start_x, start_y)
	love.graphics.setShader()
end

function water_effect.load()
	local canvas = love.graphics.newCanvas(60, 60)
	love.graphics.setCanvas(canvas)
    love.graphics.clear(1, 1, 1)
    love.graphics.setCanvas()

	water_effect.shader = love.graphics.newShader(shader2)
	local imageData = canvas:newImageData()
	water_effect.background_image = love.graphics.newImage(imageData)
end

return water_effect
