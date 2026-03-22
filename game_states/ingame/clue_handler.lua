local clue_handler = {
	active_description_clue = nil --maybe make it a list later on
}

function clue_handler.set_clues(clues)
	clue_handler.clues = clues
end 

function clue_handler.set_get_player_position(player_position_func)
	clue_handler.player_position_func = player_position_func
end

function clue_handler.can_be_discovered()
	if active_description_clue ~= nil then
		return
	end

	local all_discovered_clues = get_all_discovered_clues()
	local matcher = 
	function(clue) 
		detective_x, detective_y = clue_handler.player_position_func()

		if (not clue.is_discovered) and clue_handler.clue_all_dependencies_met(clue, all_discovered_clues) then

			if not clue.discovery_positions or next(clue.discovery_positions) == nil then
				return true -- no action required to reveal the clue, therefore return true, the value is nil or {}
			end
			-- other conditions here
			if clue.discovery_positions then 
				for i,v in ipairs(clue.discovery_positions) do
					if v[1] == detective_x and v[2] == detective_y then
						return true
					end
				end
			end

		end

		return false 
	end

	return clue_handler.match_one(matcher)
end

function clue_handler.match_one(matcher)
	for key, clue in pairs(clue_handler.clues) do
		if matcher(clue) then
			return clue
		end
	end
end

function clue_handler.is_visible_on_the_ground()
	local all_discovered_clues = get_all_discovered_clues()
	local matcher = 
	function(clue) 
		return (((not clue.is_discovered) and clue_handler.clue_all_dependencies_met(clue, all_discovered_clues))
				or (clue.is_discovered and not clue.carried)) and clue.discovery_positions
	end

	return clue_handler.find_all_matching(matcher)
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

function get_all_discovered_clues()
 	local rtn_list = {}

 	for key,clue in pairs(clue_handler.clues) do
 		if clue.is_discovered then
 			rtn_list[clue.name] = true
 			--print(clue.name)
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
	prev_x, prev_y = clue_handler.player_position_func()

	clue.is_discovered=true

	local continue_description_func = function()
		detective_x, detective_y = clue_handler.player_position_func()
		return prev_x == detective_x and prev_y == detective_y
	end

	active_description_clue = {clue, continue_description_func}
end

-- run to check and disable active descriptions
function clue_handler.check_disable_description()
	if active_description_clue and not active_description_clue[2]() then
		active_description_clue = nil
	end
end

-- return a description as text
function clue_handler.get_active_clue_description()
	if active_description_clue then
		return active_description_clue[1].description
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


