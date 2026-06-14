local ingame = {
	obstacles = {},
	detective_image = love.graphics.newImage("detective.png"),
	person_image = love.graphics.newImage("person.png"),
	mobile_phone_image = love.graphics.newImage("call_police_station.png"),
	detective = {facing_direction = 1},
	clues_images = {},
	clue_handler = require "game_states.ingame.clue_handler",
	clue_summary_control = require "game_states.ingame.clue_summary_control",
	mouse_pointer = require "game_states.mouse_pointer",
	d_p_c = require "game_states.ingame.draw_position_calculator",
	image_handler = require "game_states.ingame.image_handler",
	person_handler = require "game_states.ingame.person_handler",
	level_saver = require "level_saver",
	theme_handler = require "theme_handler",
	weather = require "weather",
	river_handler = require "game_states.ingame.river_handler",
	water_effect = require "game_states.ingame.water_effect"
}

local scale = 3

function ingame.init()
	ingame.water_effect.load()
	ingame.obstacles = {}
	ingame.obstacle_lookup = function(name) return nil end -- fresh lookup function for obstacles

	ingame.read_from_mapreader()

	for i=1,ingame.size do
		ingame.obstacles[i] = ingame.obstacles[i] or {} -- to not removed obstacles from map file
		for j=1,ingame.size do
			if not ingame.obstacles[i][j] and not ingame.clue_handler.collision_with_clue(i, j)
				and love.math.random() < 0.15 then
				ingame.obstacles[i][j] = "tree"..love.math.random(4)
			end
		end
	end
	ingame.clue_handler.set_get_player_position(
		function()
			local detective = ingame.person_handler.get_person_lookup("Detective")
			return detective[1], detective[2]
			end
	) -- refactor this later, it is more obvious to use a dictionary
	ingame.game_phase = "ongoing"
end

function ingame.read_from_mapreader()
	local mapreader = require "game_states.ingame.mapreader"

	mapreader.readfile(cur_level)

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

	ingame.compose_lookup(mapreader)
	ingame.clue_handler.set_clues(clues)
	ingame.person_handler.set_persons(mapreader.persons)
	ingame.person_handler.set_map_size(ingame.size)
	ingame.clue_handler.set_around_lookup_function(ingame.make_around_function(ingame.person_handler.get_person_lookup, ingame.obstacle_lookup))
	ingame.river_handler.set_river(mapreader.get_river(), ingame.size)
end

function ingame.compose_lookup(mapreader)
	for _,obstacle in ipairs(mapreader.obstacles) do
		ingame.add_defined_obstacle_to_lookup(obstacle)
	end
end

local function get_detective()
	local detective_lookup_data = ingame.person_handler.get_person_lookup("Detective")

	return {x=detective_lookup_data[1], y=detective_lookup_data[2]}
end

local function run_if_ready_to_arrest(func_to_run)
	local discovered_clues = ingame.clue_handler.get_discovered_summary()
	local index = ingame.clue_summary_control.get_selected_index()

	if #discovered_clues > 0 and discovered_clues[index] and discovered_clues[index].type == "person" and
		ingame.game_phase=="ongoing" then
			func_to_run()
	end
end

local function draw_persons()
	for _,person in ipairs(ingame.person_handler.persons) do
		local draw_x,draw_y = ingame.d_p_c.calc_start(get_detective().x, get_detective().y, person.x, person.y, true)
		if person.type == "person" then
			love.graphics.draw(ingame.person_image, draw_x, draw_y, 0, scale*person.facing, scale, 10, 10)
		end
		if person.type == "detective" then
			love.graphics.draw(ingame.detective_image, draw_x, draw_y, 0, scale*person.facing, scale, 10, 10)
		end
	end
end

local function draw_obstacles()
	local detective = get_detective()

	-- for obstacles
	for i = math.floor(detective.x)-10 , math.floor(detective.x)+10 do
		for j = math.floor(detective.y)-10,math.floor(detective.y)+10 do
			if ingame.obstacles[i] and ingame.obstacles[i][j] then
				local draw_x,draw_y = ingame.d_p_c.calc_start(detective.x, detective.y, i, j, true)
				love.graphics.draw(ingame.image_handler.world_img, ingame.image_handler[ingame.obstacles[i][j]] ,  draw_x, draw_y, 0, scale, scale, 10, 10)
					-- orientation, scalex, scaley, origin_offset
			else
				if (i*13+j*11)%19==0 then
					local draw_x,draw_y = ingame.d_p_c.calc_start(detective.x, detective.y, i, j, true)
					love.graphics.draw(ingame.image_handler.world_img, ingame.image_handler.plants,  draw_x, draw_y, 0, scale, scale, 10, 10)
				end
			end
		end
	end
end

local function draw_river()
	local detective = get_detective()

	for i = math.floor(detective.x)-10, math.floor(detective.x)+10 do
		for j = math.floor(detective.y)-10, math.floor(detective.y)+10 do
			if ingame.river_handler.collision_with_river(i, j) then
				local draw_x, draw_y = ingame.d_p_c.calc_start(detective.x, detective.y, i, j)
				local draw_x_end, draw_y_end = ingame.d_p_c.calc_end(detective.x, detective.y, i, j)
				ingame.water_effect.make_water_effect(draw_x, draw_y, draw_x_end, draw_y_end)
			end
		end
	end
end

local function draw_centered_text(text)
	love.graphics.printf(text, window_initial_width/2, window_initial_height/2, 300, "center", 0, 1.5, 1.5, 150)
end

local function draw_object_description()
	local description = ingame.clue_handler.get_active_clue_description()

	if description then
		draw_centered_text(description)
	end
end

local function draw_pick_up_tooltip()
	local tmp_clue = ingame.clue_handler.can_be_discovered()

	if tmp_clue then
		draw_centered_text("Use the space key to discover a clue")
	end
end

local function draw_clues()
	local to_be_drawn_on_ground_clue_positions = ingame.clue_handler.is_visible_on_the_ground()

	for _,position in ipairs(to_be_drawn_on_ground_clue_positions) do
		local image = ingame.clues_images[position.name]["display_on_ground_image"] or ingame.clues_images[position.name]["image"]
		local origin = image:getWidth()/2

		local draw_x,draw_y = ingame.d_p_c.calc_start(get_detective().x, get_detective().y, position.pos_x, position.pos_y, true)

		love.graphics.draw(image, draw_x, draw_y, 0, scale, scale, origin, origin)
	end
end

local function draw_on_victory_or_loss()
	if ingame.game_phase == "victory" then
		draw_centered_text("Success, case closed successfully, the murderer was arrested.")
	end
	if ingame.game_phase == "cold case" then
		draw_centered_text("Failure, the wrong person was arrested and the case went cold.")
	end
end

local function draw_notification_for_arrest_person()

	local around_func = ingame.make_around_function(ingame.obstacle_lookup)

	run_if_ready_to_arrest(function()
		for _,value in ipairs(around_func("police_car")) do
			local draw_x,draw_y = ingame.d_p_c.calc_start(get_detective().x, get_detective().y, value[1], value[2], true)

			love.graphics.draw(ingame.mobile_phone_image, draw_x, draw_y,  0, scale, scale, 10, 10)
		end

		if ingame.at_defined_obstacle("police_car") then
			draw_centered_text("Press space key to arrest this person")
		end
	end)
end

local function draw_map_boundary()
	local detective = get_detective()
	local prev_red, prev_green, prev_blue = love.graphics.getColor()

	for i = math.floor(detective.x)-10, math.floor(detective.x)+10 do
		for j = math.floor(detective.y)-10, math.floor(detective.y)+10 do

			if (i+j)%2==0 then
				love.graphics.setColor(0, 0, 1, 0.75)
			else
				love.graphics.setColor(1, 1, 1, 0.75)
			end

			local draw_x_start,draw_y_start = ingame.d_p_c.calc_start(detective.x, detective.y, i, j)
			local draw_x_end,draw_y_end = ingame.d_p_c.calc_end(detective.x, detective.y, i, j)

			if i == 1 and j > 0 and j<=ingame.size then
				love.graphics.line(draw_x_start, draw_y_start, draw_x_start, draw_y_end)
			end
			if i == ingame.size and j > 0 and j<=ingame.size then
				love.graphics.line(draw_x_end, draw_y_start, draw_x_end, draw_y_end)
			end

			if j == 1 and i > 0 and i<=ingame.size then
				love.graphics.line(draw_x_start, draw_y_start, draw_x_end, draw_y_start)
			end
			if j == ingame.size and i > 0 and i<=ingame.size then
				love.graphics.line(draw_x_start, draw_y_end, draw_x_end, draw_y_end)
			end
		end
	end
	love.graphics.setColor(prev_red, prev_green, prev_blue)
end

function ingame.draw()
	local bg_red, bg_green, bg_blue, bg_alpha = love.graphics.getColor()
	love.graphics.setColor(0.0, 0.375, 0.250)
	love.graphics.rectangle("fill", 0, 0, window_initial_width, window_initial_height)--this is the background
	love.graphics.setColor(bg_red, bg_green, bg_blue, bg_alpha)
	draw_obstacles()
	draw_river()
	draw_clues()
	draw_persons()

	draw_map_boundary()

	draw_pick_up_tooltip()
	draw_object_description()
	draw_on_victory_or_loss()
	draw_notification_for_arrest_person()
	ingame.clue_summary_control.draw(ingame.generate_dicovered_clues_name_iterator(), ingame.clue_summary_image_getter)
	ingame.weather.draw()
	ingame.mouse_pointer.draw()
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

function ingame.update(delta_time, transition_to_menu_state)
	if debounce_keyboard.check("escape") then
		transition_to_menu_state()
	end

	ingame.discover_action()

	ingame.clue_handler.check_disable_description()
	ingame.clue_summary_control.check_for_clue_clicked()
	ingame.call_police_station_if_person_selected()
	ingame.person_handler.move(delta_time, function(x_pos, y_pos)
		return ingame.obstacles[x_pos] and ingame.obstacles[x_pos][y_pos] or
		ingame.river_handler.collision_with_river(x_pos, y_pos)=="river"
	end
	)
	ingame.weather.update()
end

function ingame.discover_action()
	local tmp_clue = ingame.clue_handler.can_be_discovered()
	if tmp_clue and debounce_keyboard.check("space") then
		ingame.clue_handler.discover_clue(tmp_clue)
	end
end

local function add_layer_to_lookup(prev_obstacle_lookup, match_name, position)
	return function(name)
		if name == match_name then
			return position
		end
		return prev_obstacle_lookup(name)
	end
end

function ingame.add_defined_obstacle_to_lookup(obstacle)
	ingame.obstacles[obstacle.position.x] = ingame.obstacles[obstacle.position.x] or {}
	ingame.obstacles[obstacle.position.x][obstacle.position.y] = obstacle.type

	ingame.obstacle_lookup = add_layer_to_lookup(ingame.obstacle_lookup, obstacle.type, {obstacle.position.x, obstacle.position.y})
end

function ingame.call_police_station_if_person_selected()
	local discovered_clues = ingame.clue_handler.get_discovered_summary()
	local index = ingame.clue_summary_control.get_selected_index()

	run_if_ready_to_arrest(function()
		if ingame.at_defined_obstacle("police_car") then
			if debounce_keyboard.check("space") then
				if discovered_clues[index].is_murderer then
					ingame.game_phase="victory"
					ingame.level_saver.save(cur_level, "Case completed")
					ingame.theme_handler.play("victory")
				else
					ingame.game_phase="cold case"
					ingame.level_saver.save(cur_level, "Cold case")
				end
			end
		end
	end)
end

function ingame.at_defined_obstacle(obstacle)
	local detective = get_detective()
	local obstacle_position = ingame.obstacle_lookup(obstacle)

	return obstacle_position and math.abs(detective.x - obstacle_position[1]) + math.abs(detective.y - obstacle_position[2]) == 1
end

function ingame.make_around_function(...)

	local func_lookups = {...}

	return function(name)

		for _,lookup in ipairs(func_lookups) do
			if lookup then
				local position = lookup(name)

				if position then
					return {{position[1]+1, position[2]}, {position[1]-1, position[2]},
					{position[1], position[2]+1}, {position[1], position[2]-1}}
				end
			end
		end

		return {}
	end
end

return ingame
