
local person_handler = {persons = {}}

function person_handler.move(delta_time, obstacle_at_position_func)
	
	for index, person in ipairs(person_handler.persons) do
		if person.move_func then
			new_x, new_y = person.move_func(delta_time, person.x, person.y)

			if not new_x then
				person.move_func = nil
				person.x = math.floor(0.5 + person.x)
				person.y = math.floor(0.5 + person.y)
			else
				person.x = new_x
				person.y = new_y
			end
		else
			person.move_func = person_handler.make_move_func(person.behaviour, obstacle_at_position_func, person.x, person.y)
		end

	end

end

function person_handler.add_person(position, behaviour)
	table.insert(person_handler.persons, {x=position.x, y=position.y, behaviour=behaviour})
end

function person_handler.set_persons(persons)
	person_handler.persons = {}
	for _,person in ipairs(persons) do
		person_handler.add_person(person.position, person.behaviour)
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

		return 2*delta_time*xdir*normalized_length + x_pos2, 2*delta_time*ydir*normalized_length + y_pos2
	end
end


function person_handler.set_move_direction_func(behaviour)
	if behaviour == "stroll" then
		return function(obstacle_at_position_func, x_pos, y_pos)

			if love.math.random() < 0.998 then 
				return nil
			end
			
			local directions = { {1,0}, {-1,0}, {0,1}, {0,-1} }
			local direction = love.math.random(4)

			if not obstacle_at_position_func(x_pos+directions[direction][1], y_pos+directions[direction][2]) then
				return directions[direction][1], directions[direction][2]
			end

			-- set movement


		end
	end
end

-- insert detective here


return person_handler
