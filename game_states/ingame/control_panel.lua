local control_panel = {

}
local slot_size = 60
local selected = 1

local function get_index_from_mouse()
	local start_x = window_initial_width - 200

	return 1 + math.floor((love.mouse.getX()-start_x)/slot_size) + 3*math.floor(love.mouse.getY()/slot_size)
end

local function get_place_in_inventory_from_index(index)
	local adjust = index - 1

	return { x = window_initial_width + slot_size*(adjust%3) - 200, y = slot_size * math.floor(adjust/3) }
end

local function control_panel_draw(ordered_clues, image_getter)
	local prev_r,prev_g,prev_b = love.graphics.getColor()
	love.graphics.setColor(1, 1, 1, 0.05)
	love.graphics.rectangle("fill", window_initial_width - 200, 0, 200, window_initial_height)
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

	if love.mouse.getX() > window_initial_width - 200 then
		local tmp_info_selected = get_index_from_mouse()
		local place = get_place_in_inventory_from_index(get_index_from_mouse())
		if ordered_clues[tmp_info_selected] then
			love.graphics.printf(ordered_clues[tmp_info_selected].description, window_initial_width - 400, place.y, 200)
		end
	end

end

local function update_index()
	if love.mouse.getX() > window_initial_width - 200 and love.mouse.isDown(1) then
		selected = get_index_from_mouse()
	end
end

function control_panel.get_control_panel()
		local ordered_clues = {}

		return {
			control_panel_draw = function(image_getter) control_panel_draw(ordered_clues, image_getter) end,
			add_clue = function(clue) table.insert(ordered_clues, clue) end,
			get_selected_index = function() return ordered_clues[selected] end,
			update = update_index
		}
end

return control_panel
