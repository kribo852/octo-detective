-- clues can be objects, persons or footprint

local mapreader = {
	clues = {},
	name_generator = require "name_generator"
}

function mapreader.make_clue(clue)
	table.insert(mapreader.clues, {
			name = mapreader.name_tokens(clue.name),
			type = clue.type, 
			is_discovered = clue.is_discovered, 
			carried = clue.carried,
			image = clue.image,
			display_on_ground_image = clue.display_on_ground_image,
			description = mapreader.name_tokens(clue.description),
			depends_on = clue.depends_on,
			discovery_positions = clue.discovery_positions, -- discover at these positions
			discovery_wait = clue.discovery_wait
	})
end

function mapreader.set_size(size_table)
	mapreader.size = size_table.size
end

function mapreader.set_detective(detective)
	mapreader.detective = detective
end


function mapreader.readfile(filename)
	loadfile (filename, "t", 
		{
			set_size=mapreader.set_size, 
			make_clue=mapreader.make_clue,
			set_detective=mapreader.set_detective,
			set_police_car=function(police_car) mapreader.police_car=police_car end,
			none=mapreader.none_clues, 
			one=mapreader.one_clues,
			all=mapreader.all_clues
		}
	)()
end

function mapreader.none_clues()
	return function(names_of_discovered_clues) return true end -- no items needs to be discovered for this to be true
end

function mapreader.one_clues( ... )
	local collect = {...}
	return function(names_of_discovered_clues) 
		for index,value in ipairs(collect) do
			if type(value) == "string" then
				if names_of_discovered_clues[value] then
					return true
				end
			else 
				if value(names_of_discovered_clues) then
					return true
				end
			end
		end
		return false
	end
end

function mapreader.all_clues( ... )
	local collect = {...}
	return function(names_of_discovered_clues) 
		for index,value in ipairs(collect) do
			if type(value) == "string" then
				if not names_of_discovered_clues[value] then
					return false
				end
			else 
				if not value(names_of_discovered_clues) then
					return false
				end
			end
		end
		return true
	end
end

function mapreader.name_tokens(name)
	local token_box_pattern = "name%<%a+%d?%>"

	return string.gsub(name, token_box_pattern, mapreader.name_generator.replace_token_with_name)
end

return mapreader 
