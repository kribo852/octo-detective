local weather = {}

function weather.update() 
	if #weather < 500 then
		table.insert(weather, {x=love.math.random(love.graphics.getWidth()), y=0, angle=math.pi/2, speed=8})
	end 

	for index,particle in ipairs(weather) do
		weather[index] = { 
							x=particle.x+particle.speed*math.cos(particle.angle), 
							y=(particle.y+particle.speed*math.sin(particle.angle))%love.graphics.getHeight(),
							angle=particle.angle,
							speed=particle.speed
						}
	end

	for index,particle in ipairs(weather) do
		if love.math.random(35) == 1 then
			weather[index] = { x=particle.x, y=particle.y , angle=particle.angle, speed=-0.5 }
		end
		if love.math.random(5) == 1 and particle.speed < 0 then
			weather[index] = { x=particle.x, y=0 , angle=particle.angle, speed=8 }
		end
	end


end

function weather.draw()
	local r, g, b, a = love.graphics.getColor()
	love.graphics.setColor(0.1, 0.35, 0.5, 0.10)
	local prev_line_width = love.graphics.getLineWidth()
	love.graphics.setLineWidth(2)

	for index,particle in ipairs(weather) do
		love.graphics.line( particle.x, particle.y, particle.x, particle.y-20 )
	end

	love.graphics.setLineWidth(prev_line_width)
	love.graphics.setColor(r, g, b, a)
end



return weather
