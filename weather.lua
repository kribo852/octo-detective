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

	weather.update_rain_volume()
end

function weather.update_rain_volume()
	weather.rain_phase_roll = weather.rain_phase_roll + (math.pi/300)

	--weather.rain_sound1:setVolume(( 1 + math.sin(weather.rain_phase_roll) ) / 2)
	weather.rain_sound2:setVolume( -(math.sin(weather.rain_phase_roll) - 1 ) / 2)
end

function weather.draw()
	local r, g, b, a = love.graphics.getColor()
	love.graphics.setColor(0.1, 0.15, 0.2, 0.3)
	local prev_line_width = love.graphics.getLineWidth()
	love.graphics.setLineWidth(5)

	for index,particle in ipairs(weather) do
		love.graphics.line( particle.x, particle.y, particle.x, particle.y-20 )
	end

	love.graphics.setLineWidth(prev_line_width)
	love.graphics.setColor(r, g, b, a)
end

local function get_smooth_random_noise(length, smoothness)
	local white_noise = {}

	for i=1,length do
		white_noise[i] = (love.math.random() * 2 - 1)
	end

	local smooth_noise = {}
	local min = 0
	local max = 0

	for i=1,length do
		local sum = 0
		for j=-smoothness,smoothness do
			sum = sum + white_noise[((i+j+length)%length)+1]*math.exp(-2*math.abs(j / smoothness))
		end
		smooth_noise[i] = sum
		if min > sum then
			min = sum
		end
		if max < sum then
			max = sum
		end
	end

	for i=1,length do
		smooth_noise[i] = (smooth_noise[i] - min) / ((max - min) / 2) - 1
	end

	return smooth_noise
end

function weather.init()
	-- Definiera inställningar
    local sampleRate = 44100
    local duration = 5 -- Längd i sekunder

    -- Skapa en ny SoundData-behållare

    local noise1_array = get_smooth_random_noise(sampleRate*duration, 8)
    local noise2_array = get_smooth_random_noise(sampleRate*duration, 11)

    local sound_data1 = love.sound.newSoundData(sampleRate*duration, sampleRate, 16, 1)
    local sound_data2 = love.sound.newSoundData(sampleRate*duration, sampleRate, 16, 1)

    for i = 0, sampleRate*duration-1 do
    	sound_data1:setSample(i, noise1_array[i+1])
    	sound_data2:setSample(i, noise2_array[i+1])
    end


    -- Skapa en ljudkälla från datan
    weather.rain_sound1 = love.audio.newSource(sound_data1)
    weather.rain_sound2 = love.audio.newSource(sound_data2)

    weather.rain_sound1:setLooping(true)
    weather.rain_sound1:play()
    weather.rain_sound2:setLooping(true)
    weather.rain_sound2:play()
    weather.rain_phase_roll = 0
end

function weather.tear_down()
	weather.rain_sound1:stop()
	weather.rain_sound1:release()
	weather.rain_sound2:stop()
	weather.rain_sound2:release()
end



return weather
