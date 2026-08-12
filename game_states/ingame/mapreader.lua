-- clues can be objects, persons or footprints

local mapreader = {
	name_generator = require "name_generator",
	info_share = require "info_share"
}

function mapreader.make_clue(clue, clues)
	clues[mapreader.name_tokens(clue.name)] = {
			name = mapreader.name_tokens(clue.name),
			type = clue.type,
			is_murderer = clue.is_murderer,
			is_discovered = clue.is_discovered,
			carried = clue.carried,
			image = clue.image,
			display_on_ground_image = clue.display_on_ground_image,
			description = mapreader.name_tokens(clue.description),
			depends_on = clue.depends_on,
			discovery_positions = clue.discovery_positions, -- discovered at these positions
			discovery_wait = clue.discovery_wait,
			discovery_around = clue.discovery_around
	}
end

function mapreader.set_size(size_table)
	print("map size: "..size_table.size)
	mapreader.info_share.register_game_info("map_size", function() return size_table.size end)
end

function mapreader.set_detective(detective, persons)
	mapreader.add_person({name = "Detective", type = "detective", behaviour = "player", position = detective.position}, persons)
end

function mapreader.add_obstacle(obstacle)
	table.insert(mapreader.obstacles, {type=obstacle.type, position={x=obstacle.position.x, y=obstacle.position.y}})
end

function mapreader.add_person(person, persons)
	table.insert(persons, {name=mapreader.name_tokens(person.name), type=person.type, behaviour=person.behaviour, position=person.position})--name, type, behaviour, position
end

function mapreader.around(name)
	local lookup_name = mapreader.name_tokens(name)

	return function(around_function) -- input is a lookup function that takes a name and returns the surrounding positions
		return around_function(lookup_name)
	end
end

function mapreader.add_river(river)
	mapreader.info_share.register_game_info("river", function() return river end)
end

function mapreader.add_light_sources(light_sources)
	mapreader.info_share.register_game_info("light_sources", function() return light_sources end)
end

function mapreader.readfile(filename)
	local clues = {} -- clear previous data
	mapreader.obstacles = {}
	local persons = {}
	mapreader.name_generator.reset()

	loadfile ("levels/"..filename, "t",
		{
			set_size=mapreader.set_size,
			make_clue=function(clue) mapreader.make_clue(clue, clues) end,
			set_detective=function(person) mapreader.set_detective(person, persons) end,
			add_obstacle=mapreader.add_obstacle,
			add_person=function(person) mapreader.add_person(person, persons) end,
			around=mapreader.around,
			none=mapreader.none_clues,
			one=mapreader.one_clues,
			all=mapreader.all_clues,
			add_river=mapreader.add_river,
			add_light_sources=mapreader.add_light_sources 
		}
	)()

	mapreader.info_share.register_game_info("clues", function() return clues end)
	mapreader.info_share.register_game_info("persons", function() return persons end)
end

function mapreader.none_clues()
	return function(names_of_discovered_clues) return true end -- no items needs to be discovered for this to be true
end

function mapreader.one_clues( ... )
	local collect = {...}
	return function(names_of_discovered_clues)
		for _,value in ipairs(collect) do
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
		for _,value in ipairs(collect) do
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
