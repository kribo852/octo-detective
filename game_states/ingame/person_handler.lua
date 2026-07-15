local person_handler = {
	info_share = require "info_share",
	persons = {}
}

local function head_toward_direction(wanted_x, wanted_y, current_x, current_y, obstacle_at_position_func)
	local delta_x = wanted_x - current_x
	local delta_y = wanted_y - current_y
	local xdir = 0
	local ydir = 0

	if delta_x ~= 0 then
		xdir = delta_x/math.abs(delta_x)
	end
	if delta_y ~= 0 then
		ydir = delta_y/math.abs(delta_y)
	end

	if math.abs(delta_x) > math.abs(delta_y) and not obstacle_at_position_func(current_x + xdir, current_y) then
			return xdir, 0
		end

	if math.abs(delta_x) < math.abs(delta_y) and not obstacle_at_position_func(current_x, current_y + ydir) then
		return 0, ydir
	end
end

local function stroll_behaviour(obstacle_at_position_func, x_pos, y_pos)
	if love.math.random() < 0.98 then
		return nil
	end

	local map_size = person_handler.info_share.get_game_info("map_size")()

	if x_pos <= 0 or y_pos <= 0 or x_pos > map_size or y_pos > map_size then -- outside the map
		local middle_map_x = map_size/2
		local middle_map_y = map_size/2

		return head_toward_direction(middle_map_x, middle_map_y, x_pos, y_pos, obstacle_at_position_func)
	end

	local detective_position = person_handler.get_person_lookup("Detective") --find the detective
	local distance = math.sqrt((detective_position[1] - x_pos)^2 + (detective_position[2] - y_pos)^2)

	if distance <= 2 then
		return nil
	end

	if distance >= 12 then
		return head_toward_direction(detective_position[1], detective_position[2], x_pos, y_pos, obstacle_at_position_func)
	end

	local directions = { {1,0}, {-1,0}, {0,1}, {0,-1} }
	local direction = love.math.random(4)

	if not obstacle_at_position_func(x_pos+directions[direction][1], y_pos+directions[direction][2]) then
		return directions[direction][1], directions[direction][2]
	end
end

local function detective_move(obstacle_at_position_func, x_pos, y_pos)
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

	if sum_x_move == 0 and sum_y_move == 0 then
		return nil
	end

	if not obstacle_at_position_func(x_pos+sum_x_move, y_pos+sum_y_move) then
		return sum_x_move, sum_y_move
	end

	if sum_x_move ~= 0 and not obstacle_at_position_func(x_pos+sum_x_move, y_pos) then
		return sum_x_move, 0
	end

	if sum_y_move ~= 0 and not obstacle_at_position_func(x_pos, y_pos+sum_y_move) then
		return 0, sum_y_move
	end
end

local function get_new_move_direction(behaviour)
	if behaviour == "stroll" then
		return stroll_behaviour
	end
	if behaviour == "player" then
		return detective_move
	end
end

local function make_move_func(behaviour, obstacle_at_position_func, x_pos, y_pos)
	local xdir, ydir = get_new_move_direction(behaviour)(obstacle_at_position_func, x_pos, y_pos)

	if not xdir then
		return nil
	end

	local distance_to_travel = math.sqrt(xdir^2+ ydir^2)
	local distance_traveled = 0
	local normalized_length = 1/distance_to_travel

	return function(delta_time, x_pos2, y_pos2)
		if distance_traveled > distance_to_travel then
			return nil
		end

		distance_traveled = distance_traveled + 2 * delta_time

		return 2*delta_time*xdir*normalized_length + x_pos2, 2*delta_time*ydir*normalized_length + y_pos2, xdir<0 and 1 or xdir>0 and -1
	end
end

function person_handler.move(delta_time, obstacle_at_position_func)
	for _, person in ipairs(person_handler.persons) do
		if person.move_func then
			local new_x, new_y, new_facing = person.move_func(delta_time, person.x, person.y)

			if not new_x then
				person.move_func = nil
				person.x = math.floor(0.5 + person.x)
				person.y = math.floor(0.5 + person.y)
			else
				person.x = new_x
				person.y = new_y
				person.facing = new_facing or person.facing
			end
		end
		if not person.move_func then
			person.move_func = make_move_func(person.behaviour, obstacle_at_position_func, person.x, person.y)
		end
	end
end

function person_handler.set_persons()
	person_handler.persons = {}
	for _,person in ipairs(person_handler.info_share.get_game_info("persons")()) do
		table.insert(person_handler.persons,
			{
			 x=person.position.x,
			 y=person.position.y,
			 behaviour=person.behaviour,
			 name=person.name,
			 type=person.type,
			 facing=1
			})
	end
end

function person_handler.get_person_lookup(name)
	for _,person in ipairs(person_handler.persons) do
		if person.name == name then
			return {person.x, person.y}
		end
	end
end

return person_handler
