
local person_handler = {persons = {}}

function person_handler.move(delta_time, obstacle_at_position_func)
	
	for index, person in ipairs(person_handler.persons) do
		if person.move_func then
			new_x, new_y, new_facing = person.move_func(delta_time, person.x, person.y)

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
			person.move_func = person_handler.make_move_func(person.behaviour, obstacle_at_position_func, person.x, person.y)
		end

	end

end

function person_handler.set_persons(persons)
	person_handler.persons = {}
	for _,person in ipairs(persons) do
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

function person_handler.make_move_func(behaviour, obstacle_at_position_func, x_pos, y_pos)
	local xdir, ydir = person_handler.set_move_direction_func(behaviour)(obstacle_at_position_func, x_pos, y_pos)

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

function person_handler.set_move_direction_func(behaviour)
	if behaviour == "stroll" then
		return person_handler.stroll_behaviour
	end
	if behaviour == "player" then
		return person_handler.detective_move
	end
end

function person_handler.stroll_behaviour(obstacle_at_position_func, x_pos, y_pos)
	if love.math.random() < 0.98 then 
		return nil
	end
	
	local directions = { {1,0}, {-1,0}, {0,1}, {0,-1} }
	local direction = love.math.random(4)

	if not obstacle_at_position_func(x_pos+directions[direction][1], y_pos+directions[direction][2]) then
		return directions[direction][1], directions[direction][2]
	end
end

function person_handler.detective_move(obstacle_at_position_func, x_pos, y_pos)
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

return person_handler
