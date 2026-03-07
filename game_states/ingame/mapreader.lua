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

function mapreader.readfile(filename)
	loadfile (filename, "t", {set_size=mapreader.set_size, make_clue=mapreader.make_clue})()
end


return mapreader 
