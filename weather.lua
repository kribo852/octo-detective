local weather = {}

function weather.update()
	if #weather < 500 then
		table.insert(weather, {x=love.math.random(window_initial_width), y=0, angle=math.pi/2, speed=4})
	end

	for index,particle in ipairs(weather) do
		weather[index] = {
							x=particle.x+particle.speed*math.cos(particle.angle),
							y=(particle.y+particle.speed*math.sin(particle.angle))%window_initial_height,
							angle=particle.angle,
							speed=particle.speed
						}
	end

	for index,particle in ipairs(weather) do
		if love.math.random(50) == 1 then
			weather[index] = { x=particle.x, y=particle.y , angle=particle.angle, speed=-0.5 }
		end
		if love.math.random(10) == 1 and particle.speed < 0 then
			weather[index] = { x=particle.x, y=0 , angle=particle.angle, speed=5 }
		end
	end


end

function weather.draw()
	local r, g, b, a = love.graphics.getColor()
	love.graphics.setColor(0.1, 0.15, 0.2, 0.12)
	local prev_line_width = love.graphics.getLineWidth()
	love.graphics.setLineWidth(5)

	for index,particle in ipairs(weather) do
		love.graphics.line( particle.x, particle.y, particle.x, particle.y-20 )
	end

	love.graphics.setLineWidth(prev_line_width)
	love.graphics.setColor(r, g, b, a)
end

local function mix_in_audio_frequency(sound_data, amplitude, smoothness)

	local previous_sample = amplitude * (love.math.random() * 2 - 1)

	for i = 0, sound_data:getSampleCount()/2 - 1 do
		local current_sample = amplitude * (love.math.random() * 2 - 1)

        previous_sample = previous_sample * smoothness + (1 - smoothness) * current_sample

        local earlier_sample_data = sound_data:getSample( i )

        sound_data:setSample(i, previous_sample + earlier_sample_data)
        sound_data:setSample(sound_data:getSampleCount() - 1 - i, previous_sample + earlier_sample_data)
    end
end

function weather.init()
	-- Definiera inställningar
    local sampleRate = 44100
    local duration = 2 -- Längd i sekunder

    -- Skapa en ny SoundData-behållare
    local sound_data = love.sound.newSoundData(sampleRate*duration, sampleRate, 16, 1)

    mix_in_audio_frequency(sound_data, 1.0, 0.99)
    mix_in_audio_frequency(sound_data, 0.5, 0.97)
    mix_in_audio_frequency(sound_data, 0.25, 0.94)

    do --normalize
    	local min = 0
		local max = 0
    	for i=0,sound_data:getSampleCount()-1 do

    		local earlier_sample_data = sound_data:getSample( i )

    		if earlier_sample_data < min then
    			min = earlier_sample_data
    		end

    		if earlier_sample_data > max then
    			max = earlier_sample_data
    		end

    	end
    	for i = 0,sound_data:getSampleCount()-1 do
    		local earlier_sample_data = sound_data:getSample( i )
    		local new_amplitude = (earlier_sample_data - min)/(max - min)
    		sound_data:setSample(i, new_amplitude - 1)
    	end
	end


    -- Skapa en ljudkälla från datan
    weather.noiseSound = love.audio.newSource(sound_data)

    weather.noiseSound:setLooping(true)
    weather.noiseSound:play()
end

function weather.tear_down()
	weather.noiseSound:stop()
	weather.noiseSound:release()
end



return weather
