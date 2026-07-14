local control_panel = {
	info_share = require "info_share"
}
local slot_size = 60
local selected = 1
local start_of_sidebar = window_initial_width - 200

local function get_index_from_mouse()
	return 1 + math.floor((love.mouse.getX()-start_of_sidebar)/slot_size) + 3*math.floor(love.mouse.getY()/slot_size)
end

local function get_place_in_inventory_from_index(index)
	local adjust = index - 1

	return { x = start_of_sidebar + slot_size*(adjust%3), y = slot_size * math.floor(adjust/3) }
end

local function control_panel_draw(ordered_clues, image_getter)
	local prev_r,prev_g,prev_b = love.graphics.getColor()
	love.graphics.setColor(1, 1, 1, 0.05)
	love.graphics.rectangle("fill", start_of_sidebar, 0, 200, window_initial_height)
	love.graphics.setColor(prev_r,prev_g,prev_b)


	for index,value in ipairs(ordered_clues) do
		local image = image_getter(value.name)
		local scale = slot_size/image:getWidth()-- square images only
		local place = get_place_in_inventory_from_index(index)
		love.graphics.draw(image, place.x, place.y, 0, scale, scale)
	end

	love.graphics.setColor(0.7, 1, 1, 0.25)
	local place = get_place_in_inventory_from_index(selected)
	love.graphics.rectangle("line", place.x , place.y, slot_size, slot_size)
	love.graphics.setColor(prev_r,prev_g,prev_b)

	if love.mouse.getX() > start_of_sidebar then
		local tmp_info_selected = get_index_from_mouse()
		local place = get_place_in_inventory_from_index(get_index_from_mouse())
		if ordered_clues[tmp_info_selected] then
			love.graphics.printf(ordered_clues[tmp_info_selected].description, start_of_sidebar-200, place.y, 200)
		end
	end
end

local function draw_minimap(get_player_position)
	local map_size = control_panel.info_share.get_game_info("map_size")()
	local player_position = get_player_position()
	love.graphics.rectangle("line", start_of_sidebar, window_initial_height - 100, map_size, map_size)
	love.graphics.points(start_of_sidebar + player_position.x, window_initial_height - 100 + player_position.y)
end

local function update_index()
	if love.mouse.getX() > start_of_sidebar and love.mouse.isDown(1) then
		selected = get_index_from_mouse()
	end
end

function control_panel.get_control_panel()
		local ordered_clues = {}

		return {
			control_panel_draw = function(image_getter) control_panel_draw(ordered_clues, image_getter) end,
			add_clue = function(clue) table.insert(ordered_clues, clue) end,
			get_selected_index = function() return ordered_clues[selected] end,
			update = update_index,
			draw_minimap = draw_minimap
		}
end

return control_panel
