local clue_handler = {

}

local function get_all_discovered_clues()
 	local rtn_list = {}

 	for key,clue in pairs(clue_handler.clues) do
 		if clue.is_discovered then
 			rtn_list[clue.name] = true
 			--print(clue.name)
 		end
 	end
 	return rtn_list
end

local function match_one(matcher)
	for _, clue in pairs(clue_handler.clues) do
		if matcher(clue) then
			return clue
		end
	end
end

function clue_handler.set_clues(clues)
	clue_handler.clues = clues
end

function clue_handler.set_get_player_position(player_position_func)
	clue_handler.player_position_func = player_position_func
end

--The function is composed to take a name and return all positions around the object with the name
function clue_handler.set_around_lookup_function(around_lookup_func)
	clue_handler.around_lookup_func = around_lookup_func -- lookup_func(name) -> position[]
end

function clue_handler.can_be_discovered()
	if clue_handler.active_description_clue ~= nil then
		return
	end

	local all_discovered_clues = get_all_discovered_clues()
	local matcher =
	function(clue)
		local detective_position = clue_handler.player_position_func()

		if (not clue.is_discovered) and clue_handler.clue_all_dependencies_met(clue, all_discovered_clues) then
			if clue.discovery_positions and next(clue.discovery_positions) then
				if clue.discovery_positions then
					for _,around_clue_position in ipairs(clue.discovery_positions) do
						if around_clue_position[1] == detective_position.x and around_clue_position[2] == detective_position.y then
							return true
						end
					end
				end
				return false
			end

			if clue.discovery_around then
				for _,around_clue_position in ipairs(clue.discovery_around(clue_handler.around_lookup_func)) do -- around_func(name) -> positions[] 
					if around_clue_position[1] == detective_position.x and around_clue_position[2] == detective_position.y then
						return true
					end
				end
				return false
			end

			return true -- no particular conditions apply for this clue to be discovered
		end

		return false
	end

	return match_one(matcher)
end

function clue_handler.is_visible_on_the_ground()
	local all_discovered_clues = get_all_discovered_clues()
	local matcher =
	function(clue)
		return (((not clue.is_discovered) and clue_handler.clue_all_dependencies_met(clue, all_discovered_clues))
				or (clue.is_discovered and not clue.carried))
	end

	local clues_to_draw = clue_handler.find_all_matching(matcher)
	local rtn_stripped_clue_information = {}

	for _,value in ipairs(clues_to_draw) do
		if value.discovery_positions then
			for _,position_value in ipairs(value.discovery_positions) do
				table.insert(rtn_stripped_clue_information, {pos_x = position_value[1], pos_y = position_value[2], name=value.name })
			end
		end

		if value.discovery_around then
			for _,position_value in ipairs(value.discovery_around(clue_handler.around_lookup_func)) do
				table.insert(rtn_stripped_clue_information, {pos_x = position_value[1], pos_y = position_value[2], name=value.name })
			end
		end
	end
	return rtn_stripped_clue_information
end

function clue_handler.get_discovered_summary()
	local matcher = function(clue) return clue.is_discovered end
	return clue_handler.find_all_matching(matcher)
end

function clue_handler.find_all_matching(matcher)
	local rtn_list = {}

	for key,clue in pairs(clue_handler.clues) do
		if matcher(clue) then
			table.insert(rtn_list, clue)
		end
	end

	return rtn_list
end

--discovered is a map where the keys are the names of the clues
function clue_handler.clue_all_dependencies_met(clue, discovered)
	return clue.depends_on(discovered)
end

--discover the clue, and add its description to the active descriptions
function clue_handler.discover_clue(clue)
	local prev_detective_pos = clue_handler.player_position_func()

	clue.is_discovered=true

	local continue_description_func = function()
		local detective_pos = clue_handler.player_position_func()
		return prev_detective_pos.x == detective_pos.x and prev_detective_pos.y == detective_pos.y
	end

	clue_handler.active_description_clue = {clue, continue_description_func}
end

-- run to check and disable active descriptions
function clue_handler.check_disable_description()
	if clue_handler.active_description_clue and not clue_handler.active_description_clue[2]() then
		clue_handler.active_description_clue = nil
	end
end

-- return a description as text
function clue_handler.get_active_clue_description()
	if clue_handler.active_description_clue then
		return clue_handler.active_description_clue[1].description
	end
end

function clue_handler.collision_with_clue(xpos, ypos)
	for key,value in pairs(clue_handler.clues) do
		if not value.discovery_positions then
			goto continue
		end

		for i,v in ipairs(value.discovery_positions) do
			if v[1] == xpos and v[2] == ypos then
				return key
			end
		end
		::continue::
	end
	return false
end

return clue_handler


