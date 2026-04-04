local level_selector = {
	mouse_pointer = require "game_states.mouse_pointer"
}

local function make_button(index, name)
	return {xmin = 50, xmax = 500, ymin = 50+index*25, ymax = 70+index*25, name=name }
end

local function read_files_in_directory()
	if not level_selector.found_level_buttons then
		local files = love.filesystem.getDirectoryItems("levels")
		level_selector.found_level_buttons = {}
		for i,v in ipairs(files) do
			if v:match("^map%d+%.lua$") then
				table.insert(level_selector.found_level_buttons, make_button(i, v))
			end
		end
	end
end

function level_selector.update(delta_time, transition_to_forward_state)
	read_files_in_directory()

	if love.mouse.isDown(1) then
		for i,v in ipairs(level_selector.found_level_buttons) do
			if love.mouse.getX() >= v.xmin and love.mouse.getX() < v.xmax and 
				love.mouse.getY() >= v.ymin and love.mouse.getY() < v.ymax then
				cur_level = "levels/"..v.name
				print(cur_level)
				transition_to_forward_state()
				break
			end	
		end
	end
end


function level_selector.draw()
	level_selector.mouse_pointer.draw()

	if level_selector.found_level_buttons then
 		for i,v in ipairs(level_selector.found_level_buttons) do
 			love.graphics.print(v.name, 100, v.ymin)
 		end
 	end
end

return level_selector
