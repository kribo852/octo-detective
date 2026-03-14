-- clues can be objects, persons or footprint

local mapreader = {
	clues = {},
}

function mapreader.make_clue(clue)
	table.insert(mapreader.clues, {
			name = clue.name,
			type = clue.type, 
			is_discovered = clue.is_discovered, 
			carried = clue.carried,
			image = clue.image, 
			description = clue.description,
			depends_on = clue.depends_on,
			action = clue.action -- action to unlock, when all dependencies are fulfilled, these are anded together
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
			none=mapreader.none, 
			one=mapreader.one,
			all=mapreader.all
		}
	)()
end

function mapreader.none()
	return function(names_of_discovered_clues) return true end -- no items needs to be discovered for this to be true
end

function mapreader.one( ... )
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

function mapreader.all( ... )
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


return mapreader 
