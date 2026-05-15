local level_saver = {}

local function load_from_directory(level_completion_file_name)
	local string_contents = love.filesystem.read(level_completion_file_name)
	if string_contents then
		local contents = loadstring(string_contents)()
		return contents 
	end
	return {state="not finished"}
end

function level_saver.save(level_file_name, state)
	local level_completion_file_name = string.gsub(level_file_name, "%.lua", "completion_state.lua")
	--local completion_data = load_from_directory(level_completion_file_name)

	love.filesystem.write(level_completion_file_name, 'return {state="'..state..'"}')	

end

function level_saver.load_state(level_file_name)
	local level_completion_file_name = string.gsub(level_file_name, "%.lua", "completion_state.lua")
	
	print("read this completion data: "..level_completion_file_name)
	local completion_data = load_from_directory(level_completion_file_name)

	return completion_data.state

end

return level_saver