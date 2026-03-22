local ingame = {
	obstacles = {}, 
	world_img = love.graphics.newImage("objects.png"), 
	detective_image = love.graphics.newImage("detective.png"),
	police_car_img = love.graphics.newImage("police_car.png"),
	detective = {facing_direction=1},
	clues_images = {},
	clues = {},
	clue_handler = require "game_states.ingame.clue_handler"
}

function ingame.init()
	ingame.obstacles = {}
	
	ingame.read_from_mapreader()

	for i=1,ingame.size do
		ingame.obstacles[i] = {}
		for j=1,ingame.size do
			if not ingame.clue_handler.collision_with_clue(i, j) and love.math.random() < 0.3 then
				ingame.obstacles[i][j] = "tree"
			end
		end
	end
	ingame.clue_handler.set_get_player_position(function() return ingame.detective.x, ingame.detective.y end)
end

function ingame.read_from_mapreader()
	mapreader = require "game_states.ingame.mapreader"

	mapreader.readfile("levels/map1.lua")

	ingame.depends_on = mapreader.depends_on
	ingame.size = mapreader.size
	print("map size: "..ingame.size)

	local clues = {}

	for i=1,#mapreader.clues do
		if(not ingame.clues_images[mapreader.clues[i].name]) then
			ingame.clues_images[mapreader.clues[i].name] = {}
			ingame.clues_images[mapreader.clues[i].name]["image"] = love.graphics.newImage(mapreader.clues[i].image)
			if mapreader.clues[i].display_on_ground_image then 
				ingame.clues_images[mapreader.clues[i].name]["display_on_ground_image"] = love.graphics.newImage(mapreader.clues[i].display_on_ground_image)
			end
		end
		clues[mapreader.clues[i].name] = mapreader.clues[i]
	end

	ingame.detective.x = mapreader.detective.position.x
	ingame.detective.y = mapreader.detective.position.y

	ingame.spawn_police_car(mapreader.police_car)

	ingame.clue_handler.set_clues(clues)

	mapreader = nil
end

function ingame.draw()
	local scale = 3
	local screen_w = love.graphics.getWidth()
	local screen_h = love.graphics.getHeight()

	ingame.draw_obstacles()

	ingame.draw_clues()

	ingame.draw_clues_in_summary()
	 
	-- draw the detective
	love.graphics.draw(ingame.detective_image, screen_w/2, screen_h/2, 0, scale*ingame.detective.facing_direction, scale, 10, 10) 

	ingame.draw_pick_up_tooltip()

	ingame.draw_object_description()
end

function ingame.draw_obstacles()

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
				if ingame.obstacles[i][j] == "police_car" then
					love.graphics.draw(ingame.police_car_img,  
					square_size*i-square_size*ingame.detective.x+screen_w/2, 
					square_size*j-square_size*ingame.detective.y+screen_h/2, 
					0, scale, scale, 10, 10)
					-- orientation, scalex, scaley, origin_offset
				else 
					love.graphics.draw(ingame.world_img, tree, 
					square_size*i-square_size*ingame.detective.x+screen_w/2, 
					square_size*j-square_size*ingame.detective.y+screen_h/2, 
					0, scale, scale, 10, 10)
					-- orientation, scalex, scaley, origin_offset
				end
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
end


function ingame.draw_clues()
	local square_size = 60
	local screen_w = love.graphics.getWidth()
	local screen_h = love.graphics.getHeight()

	local to_be_drawn_on_ground_clue_positions = ingame.clue_handler.is_visible_on_the_ground()

	for _,position in ipairs(to_be_drawn_on_ground_clue_positions) do
		local image = ingame.clues_images[position.name]["display_on_ground_image"] or ingame.clues_images[position.name]["image"]
		local scale = square_size/image:getWidth()-- square images only
		local origin = image:getWidth()/2

		love.graphics.draw(image, screen_w/2-square_size*(ingame.detective.x-position.pos_x), 
			screen_h/2-square_size*(ingame.detective.y-position.pos_y), 0, scale, scale, origin, origin)
	end
end

function ingame.draw_clues_in_summary() 
	local square_size = 60
	local prev_r,prev_g,prev_b = love.graphics.getColor()
	love.graphics.setColor(0.5, 0.4, 0.4, 0.25)
	love.graphics.rectangle("fill", 50, 0, love.graphics.getWidth()-100, square_size)
	love.graphics.setColor(prev_r,prev_g,prev_b)

	--in this function, we don't care about the origin
	local placement = 50
	for index,clue in ipairs(ingame.clue_handler.get_discovered_summary()) do
		local image = ingame.clues_images[clue.name]["image"]
		local scale = square_size/image:getWidth()-- square images only
		love.graphics.draw(image, placement+(index-1)*square_size, 0, 0, scale, scale)
	end
end

function ingame.draw_pick_up_tooltip() 
	local tmp_clue = ingame.clue_handler.can_be_discovered()
	local screen_w = love.graphics.getWidth()
	local screen_h = love.graphics.getHeight()

	if tmp_clue then
		ingame.draw_centered_text("Use the space key to discover a clue")
	end

end

function ingame.draw_object_description() 
	local description = ingame.clue_handler.get_active_clue_description()

	if description then
		ingame.draw_centered_text(description)
	end
end

function ingame.draw_centered_text(text)
	love.graphics.printf(text, love.graphics.getWidth()/2, love.graphics.getHeight()/2, 300, "center", 0, 1.5, 1.5, 150)
end

function ingame.update(delta_time, transition_to_menu_state)
	if love.keyboard.isDown("escape") then
		transition_to_menu_state()
	end 

	if love.keyboard.isDown("space") then
		ingame.discover_action()
	end

	move_player(delta_time)

	ingame.clue_handler.check_disable_description()
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

function ingame.discover_action()
	local tmp_clue = ingame.clue_handler.can_be_discovered()
	if tmp_clue then
		ingame.clue_handler.discover_clue(tmp_clue)
	end
end

function ingame.spawn_police_car(police_car)
	ingame.obstacles[police_car.position.x] = {}
	ingame.obstacles[police_car.position.x][police_car.position.y] = "police_car"
end

return ingame
