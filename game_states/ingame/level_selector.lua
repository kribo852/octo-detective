local level_selector = {
	mouse_pointer = require "game_states.mouse_pointer",
	meta_menu = require "game_states.meta_menu"
}

local function read_files_in_directory()
	if not level_selector.found_levels then
		local files = love.filesystem.getDirectoryItems("levels")
		level_selector.found_levels = {}
		for i,file_name in ipairs(files) do
			if file_name:match("^map%d+%.lua$") then
				table.insert(level_selector.found_levels, file_name)
			end
		end
	end
end

function level_selector.update(delta_time, transition_to_forward_state)
	read_files_in_directory()
	local level_meta_data = {}

	for i,file_name in ipairs(level_selector.found_levels) do
		table.insert(level_meta_data, 
			{
			type="button",
			action=function() 
				cur_level = "levels/"..file_name
				print(cur_level)
				transition_to_forward_state() 
			end
		})
	end
	local menu_obj = level_selector.meta_menu.get_menu_layout(level_meta_data)
	menu_obj.update()
end


function level_selector.draw()
	level_selector.mouse_pointer.draw()

	local level_meta_data = {}

	for i,file_name in ipairs(level_selector.found_levels) do
		table.insert(level_meta_data, {type="button",value=file_name})
	end
	local menu_obj = level_selector.meta_menu.get_menu_layout(level_meta_data)
	menu_obj.draw()
end

return level_selector
