local ingame = {
	obstacles = {}, 
	world_img = love.graphics.newImage("objects.png"), 
	detective_image = love.graphics.newImage("detective.png"),
	detective = {facing_direction=1},
	clues_images = {},
	clues = {}
}

function ingame.init()

	ingame.obstacles = {}
	ingame.clues = {}

	ingame.read_from_mapreader()

	for i=1,ingame.size do
		ingame.obstacles[i] = {}
		for j=1,ingame.size do
			if ingame.no_collision_clues(i, j) and love.math.random() < 0.18 then
				ingame.obstacles[i][j] = "tree"
			end
		end
	end

	ingame.detective.x = ingame.size/2
	ingame.detective.y = ingame.size/2
end

function ingame.read_from_mapreader()
	mapreader = require "game_states.ingame.mapreader"

	mapreader.readfile("levels/map1.lua")

	ingame.depends_on = mapreader.depends_on
	ingame.size = mapreader.size
	print("map size: "..ingame.size)

	for i=1,#mapreader.clues do
		if(not ingame.clues_images[mapreader.clues[i].name]) then
			ingame.clues_images[mapreader.clues[i].name] = love.graphics.newImage(mapreader.clues[i].image)
		end
		ingame.clues[mapreader.clues[i].name] = mapreader.clues[i]
	end

	mapreader = nil
end

function ingame.draw()

	local square_size = 60
	local tree = love.graphics.newQuad(0, 0, 20, 20, ingame.world_img)
	local grass = love.graphics.newQuad(20, 0, 20, 20, ingame.world_img)
	local scale = 3
	local screen_w = love.graphics.getWidth()
	local screen_h = love.graphics.getHeight()

	-- for obstacles
	for i = math.floor(ingame.detective.x)-10 , math.floor(ingame.detective.x)+10 do
		for j = math.floor(ingame.detective.y)-10,math.floor(ingame.detective.y)+10 do
			if ingame.obstacles[i] and ingame.obstacles[i][j] then
				love.graphics.draw(ingame.world_img, tree, 
				square_size*i-square_size*ingame.detective.x+screen_w/2, 
				square_size*j-square_size*ingame.detective.y+screen_h/2, 
				0, scale, scale, 10, 10)
				-- orientation, scalex, scaley, origin_offset
			else
				if (i*13+j*11)%19==0 then
					love.graphics.draw(ingame.world_img, grass, 
					square_size*i-square_size*ingame.detective.x+screen_w/2, 
					square_size*j-square_size*ingame.detective.y+screen_h/2, 
					0, scale, scale, 10, 10)
				end
			end
		end
	end

	ingame.draw_clues()
	 
	-- draw the detective
	love.graphics.draw(ingame.detective_image, screen_w/2, screen_h/2, 0, scale*ingame.detective.facing_direction, scale, 10, 10) 

	ingame.draw_pick_up_tooltip()
end

function ingame.draw_clues()
	local square_size = 60
	local screen_w = love.graphics.getWidth()
	local screen_h = love.graphics.getHeight()

	for key,value in pairs(ingame.clues) do
		if value.carried and value.is_discovered then goto continue end

		local object_position_x = value.action.position[1]
		local object_position_y = value.action.position[2]
		local scale = square_size/ingame.clues_images[key]:getWidth()-- square images only
		local origin = ingame.clues_images[key]:getWidth()/2

		love.graphics.draw(ingame.clues_images[key], screen_w/2-square_size*(ingame.detective.x-object_position_x), 
		screen_h/2-square_size*(ingame.detective.y-object_position_y), 0, scale, scale, origin, origin)

		::continue::
	end

	ingame.draw_clues_in_summary()
end

function ingame.draw_clues_in_summary() 
	local square_size = 60
	local prev_r,prev_g,prev_b = love.graphics.getColor()
	love.graphics.setColor(0.5, 0.4, 0.4, 0.25)
	love.graphics.rectangle("fill", 50, 0, love.graphics.getWidth()-100, square_size)
	love.graphics.setColor(prev_r,prev_g,prev_b)

	--in this function, we don't care about the origin
	local placement = 50
	for key,value in pairs(ingame.clues) do
		if ingame.clues[key].is_discovered then
			local scale = square_size/ingame.clues_images[key]:getWidth()-- square images only
			love.graphics.draw(ingame.clues_images[key], placement, 0, 0, scale, scale)
			placement = placement + square_size
		end
	end
end

function ingame.draw_pick_up_tooltip() 
	for key,value in pairs(ingame.clues) do
		local object_position_x = value.action.position[1]
		local object_position_y = value.action.position[2]
		local screen_w = love.graphics.getWidth()
		local screen_h = love.graphics.getHeight()
		if not value.is_discovered then
			if(object_position_x == ingame.detective.x and object_position_y == ingame.detective.y) then
				love.graphics.print("use the space key to discover object", screen_w/2, screen_h/2)
			end
		end
	end
end

function ingame.update(delta_time, transition_to_menu_state)
	if love.keyboard.isDown("escape") then
		transition_to_menu_state()
	end 

	if love.keyboard.isDown("space") then
		ingame.pick_up_object()
	end

	move_player(delta_time)
end

function move_player(delta_time)

	if ingame.detective.move_function then
		local xdir, ydir = ingame.detective.move_function(delta_time)

		if math.abs(xdir) > 0 then
			ingame.detective.facing_direction = -xdir/math.abs(xdir)
		end

		if xdir == 0 and ydir == 0 then
			ingame.detective.move_function = nil
			ingame.detective.x = math.floor(ingame.detective.x + 0.5)
			ingame.detective.y = math.floor(ingame.detective.y + 0.5)
		else
			ingame.detective.x = ingame.detective.x + xdir
			ingame.detective.y = ingame.detective.y + ydir
		end
	end


	if ingame.detective.move_function then
		return
	end


	local sum_x_move = 0
	local sum_y_move = 0

	if love.keyboard.isDown("up") then
		sum_y_move = sum_y_move - 1
	end

	if love.keyboard.isDown("down") then
		sum_y_move = sum_y_move + 1
	end

	if love.keyboard.isDown("left") then
		sum_x_move = sum_x_move - 1
	end

	if love.keyboard.isDown("right") then
		sum_x_move = sum_x_move + 1
	end

	ingame.detective.move_function = make_move_function(sum_x_move, sum_y_move, ingame.detective.x, ingame.detective.y)
end

function make_move_function(xdir, ydir, x_pos, y_pos)

	if xdir == 0 and ydir == 0 then
		return function() return 0, 0 end
	end

	if ingame.obstacles[x_pos+xdir] and ingame.obstacles[x_pos+xdir][y_pos+ydir] then
		return function() return 0, 0 end 
	end

	local distance_to_travel = math.sqrt(xdir^2 + ydir^2)
	local traveled = 0

	return function(delta_time)
		if traveled > distance_to_travel then
			return 0, 0
		end
		local travel_part = 2 * delta_time -- here speed can be adjusted
		traveled = traveled + travel_part

		return (xdir*travel_part)/distance_to_travel, (ydir*travel_part)/distance_to_travel
	end
end

function ingame.no_collision_clues(xpos, ypos)
	for key,value in pairs(ingame.clues) do
		local object_position_x = value.action.position[1]
		local object_position_y = value.action.position[2]

		if object_position_x == xpos and object_position_y == ypos then
			return false
		end
	end
	return true
end

function ingame.pick_up_object()
	for key,value in pairs(ingame.clues) do
		local object_position_x = value.action.position[1]
		local object_position_y = value.action.position[2]

		if object_position_x == ingame.detective.x and object_position_y == ingame.detective.y then
			value.is_discovered = true
		end
	end
end


return ingame
