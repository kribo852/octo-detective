local ingame = {
	obstacles = {}, 
	world_img = love.graphics.newImage("objects.png"), 
	detective_image = love.graphics.newImage("detective.png"),
	police_car_img = love.graphics.newImage("police_car.png"),
	mobile_phone_image = love.graphics.newImage("call_police_station.png"),
	detective = {facing_direction=1},
	clues_images = {},
	clue_handler = require "game_states.ingame.clue_handler",
	clue_summary_control = require "game_states.ingame.clue_summary_control",
}

local square_size = 60
local scale = 3

function ingame.init()
	ingame.obstacles = {}
	
	ingame.read_from_mapreader()

	for i=1,ingame.size do
		ingame.obstacles[i] = {}
		for j=1,ingame.size do
			if not ingame.clue_handler.collision_with_clue(i, j) and love.math.random() < 0.15 then
				ingame.obstacles[i][j] = "tree"
			end
		end
	end
	ingame.clue_handler.set_get_player_position(function() return ingame.detective.x, ingame.detective.y end)
	ingame.game_state = "ongoing"
end

function ingame.read_from_mapreader()
	local mapreader = require "game_states.ingame.mapreader"

	mapreader.readfile("levels/map1.lua")

	ingame.depends_on = mapreader.depends_on
	ingame.size = mapreader.size
	print("map size: "..ingame.size)

	local clues = {}

	for i=1, #mapreader.clues do
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
end

local function run_if_ready_to_arrest(func_to_run)
	local discovered_clues = ingame.clue_handler.get_discovered_summary()
	local index = ingame.clue_summary_control.get_selected_index()

	if #discovered_clues > 0 and discovered_clues[index] and discovered_clues[index].type == "person" and 
		ingame.game_state=="ongoing" then
			func_to_run()
	end
end

local function draw_obstacles()
	local tree = love.graphics.newQuad(0, 0, 20, 20, ingame.world_img)
	local grass = love.graphics.newQuad(20, 0, 20, 20, ingame.world_img)
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

local function draw_centered_text(text)
	love.graphics.printf(text, love.graphics.getWidth()/2, love.graphics.getHeight()/2, 300, "center", 0, 1.5, 1.5, 150)
end

local function draw_object_description() 
	local description = ingame.clue_handler.get_active_clue_description()

	if description then
		draw_centered_text(description)
	end
end

local function draw_pick_up_tooltip() 
	local tmp_clue = ingame.clue_handler.can_be_discovered()
	local screen_w = love.graphics.getWidth()
	local screen_h = love.graphics.getHeight()

	if tmp_clue then
		draw_centered_text("Use the space key to discover a clue")
	end
end

local function draw_clues()
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

local function draw_on_victory()
	if ingame.game_state == "victory" then
		draw_centered_text("Success, case closed successfully, the murderer was arrested.")
	end
end

local function draw_notification_for_arrest_person()
	local discovered_clues = ingame.clue_handler.get_discovered_summary()
	local index = ingame.clue_summary_control.get_selected_index()
	local screen_w = love.graphics.getWidth()
	local screen_h = love.graphics.getHeight()

	run_if_ready_to_arrest(function()
		for i = math.floor(ingame.detective.x)-10, math.floor(ingame.detective.x)+10 do
			for j = math.floor(ingame.detective.y)-10, math.floor(ingame.detective.y)+10 do
				if ingame.obstacles[i] and ingame.obstacles[i][j] then
					if ingame.obstacles[i][j] == "police_car" then
						love.graphics.draw(ingame.mobile_phone_image, 
							square_size*(i+1)-square_size*ingame.detective.x+screen_w/2, 
							square_size*j-square_size*ingame.detective.y+screen_h/2, 
						0, scale, scale, 10, 10)

						love.graphics.draw(ingame.mobile_phone_image, 
							square_size*(i-1)-square_size*ingame.detective.x+screen_w/2, 
							square_size*j-square_size*ingame.detective.y+screen_h/2, 
						0, scale, scale, 10, 10)

						love.graphics.draw(ingame.mobile_phone_image, 
							square_size*i-square_size*ingame.detective.x+screen_w/2, 
							square_size*(j+1)-square_size*ingame.detective.y+screen_h/2, 
						0, scale, scale, 10, 10)

						love.graphics.draw(ingame.mobile_phone_image, 
							square_size*i-square_size*ingame.detective.x+screen_w/2, 
							square_size*(j-1)-square_size*ingame.detective.y+screen_h/2, 
						0, scale, scale, 10, 10)
						goto double_break
					end
				end
			end
		end
		::double_break::
		if ingame.at_police_car(ingame.detective.x, ingame.detective.y) then
			draw_centered_text("Press space key to arrest this person")
		end
	end)
end

function ingame.draw()
	local screen_w = love.graphics.getWidth()
	local screen_h = love.graphics.getHeight()

	draw_obstacles()

	draw_clues()

	ingame.clue_summary_control.draw(ingame.generate_dicovered_clues_name_iterator(), ingame.clue_summary_image_getter)
	 
	-- draw the detective
	love.graphics.draw(ingame.detective_image, screen_w/2, screen_h/2, 0, scale*ingame.detective.facing_direction, scale, 10, 10) 

	draw_pick_up_tooltip()

	draw_object_description()
	draw_on_victory()
	draw_notification_for_arrest_person()
end

function ingame.generate_dicovered_clues_name_iterator()
	local index = 0
	local discovered_clues = ingame.clue_handler.get_discovered_summary()

	return function()
		index=index+1
		if index <= #discovered_clues then
			return index,discovered_clues[index].name
		end	
	end
end

function ingame.clue_summary_image_getter(image_name)
 	return ingame.clues_images[image_name]["image"]
end 

local function get_obstacle_for_position(x_pos, y_pos)
	if ingame.obstacles[math.floor(x_pos+0.5)] then
		return ingame.obstacles[math.floor(x_pos+0.5)][math.floor(y_pos+0.5)]
	end
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
	ingame.clue_summary_control.check_for_clue_clicked()
	ingame.call_police_station_if_person_selected()
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

function ingame.call_police_station_if_person_selected()
	local discovered_clues = ingame.clue_handler.get_discovered_summary()
	local index = ingame.clue_summary_control.get_selected_index()

	run_if_ready_to_arrest(function()
		if ingame.at_police_car(ingame.detective.x, ingame.detective.y) then
			if discovered_clues[index].is_murderer then
				if love.keyboard.isDown("space") then
					ingame.game_state="victory"
				end
			end
		end
	end)
end

function ingame.at_police_car(det_x, det_y)
	return get_obstacle_for_position(det_x+1, det_y) == "police_car" or get_obstacle_for_position(det_x-1, det_y) == "police_car" or
			get_obstacle_for_position(det_x, det_y+1) == "police_car" or get_obstacle_for_position(det_x, det_y-1) == "police_car"
end

return ingame
