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
	local all_discovered_clues = get_all_discovered_clues()
	local matcher = 
	function(clue) 
		detective_x, detective_y = clue_handler.player_position_func()

		if (not clue.is_discovered) and clue_handler.clue_all_dependencies_met(clue, all_discovered_clues) then

			if not clue.action or next(clue.action) == nil then
				return true -- no action required to reveal the clue, therefore return true
			end
			-- other conditions here
			if clue.action.position then 
				if clue.action.position[1] == detective_x and clue.action.position[2] == detective_y then
					return true
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
		return ((not clue.is_discovered) and clue_handler.clue_all_dependencies_met(clue, all_discovered_clues))
				or clue.is_discovered and not clue.carried
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
	detective_x, detective_y = clue_handler.player_position_func()

	clue.is_discovered=true

	local continue_description_func = function()
		return clue.action and clue.action.position and clue.action.position[1] == detective_x 
		and clue.action.position[2] == detective_y
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
		if not value.action or not value.action.position then
			return false
		end

		local object_position_x = value.action.position[1]
		local object_position_y = value.action.position[2]

		if object_position_x == xpos and object_position_y == ypos then
			return key
		end
	end
	return false
end

return clue_handler


