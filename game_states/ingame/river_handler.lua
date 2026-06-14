--this file handles a single river, it tells the ingame where the parts of the river are  

local river_handler = {

}

local function pre_set_outside_map(river, map_size)
	local prev = river_handler.collision_with_river

	if river.x0_y then
		river_handler.collision_with_river = function (x_pos, y_pos)
			if x_pos < 1 then
				if river.x0_y == y_pos then
					return "river"
				end
			end
			return prev(x_pos, y_pos)
		end
	end

	if river.x1_y then
		river_handler.collision_with_river = function (x_pos, y_pos)
			if x_pos > river.map_size then
				if river.x1_y == y_pos then
					return "river"
				end
			end
			return prev(x_pos, y_pos)
		end
	end

	if river.y0_x then
		river_handler.collision_with_river = function (x_pos, y_pos)
			if y_pos < 1 then
				if river.y0_x == y_pos then
					return "river"
				end
			end
			return prev(x_pos, y_pos)
		end
	end

	if river.y1_x then
		river_handler.collision_with_river = function (x_pos, y_pos)
			if x_pos > river.map_size then
				if river.y1_x == y_pos then
					return "river"
				end
			end
			return prev(x_pos, y_pos)
		end
	end
end

local function make_inside_map_river(river, map_size)
	local current_x, current_y;
	local current_clause = 1
	local countdown = river.run[current_clause] and river.run[current_clause][2]
	local direction_x 
	local direction_y

	if river.x0_y then
		current_x = 1
		current_y = river.x0_y
		direction_x = 1
		direction_y = 0
	end

	while current_x > 0 and current_x <= map_size and current_y > 0 and current_y <= map_size do
 		river_handler.inside_map_lookup[tostring(current_x).."#"..tostring(current_y)] = "river"
 		current_x = current_x  + direction_x
 		current_y = current_y  + direction_y

 		if countdown then
 			countdown = countdown - 1

 			if countdown <= 0 then
 				local tmp_dir = direction_y
 				if river.run[current_clause][1] == "clockwise" then
 					direction_y = direction_x
 					direction_x = -tmp_dir
 				else
 					direction_y = -direction_x
 					direction_x = tmp_dir
 				end

 				current_clause = current_clause + 1
 				countdown = river.run[current_clause] and river.run[current_clause][2]
 			end
 		end
 	end

 	local prev_func = river_handler.collision_with_river

	river_handler.collision_with_river = function (x_pos, y_pos)
		if x_pos > 0 and x_pos <= map_size and y_pos > 0 and y_pos <= map_size then
			return river_handler.inside_map_lookup[tostring(x_pos).."#"..tostring(y_pos)]
		end

		return prev_func(x_pos, y_pos)
	end

end

function river_handler.set_river(river, map_size)
	river_handler.collision_with_river = function (x_pos, y_pos) return nil end
	river_handler.inside_map_lookup = {}

	if not river then
		return
	end

 	pre_set_outside_map(river, map_size)
 	make_inside_map_river(river, map_size)

end

return river_handler

