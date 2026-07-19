local control_panel = {
	info_share = require "info_share"
}
local slot_size = 60
local selected = 1
local start_of_sidebar = window_initial_width - 200
local minimap_size = 100

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
		local image_draw_function = image_getter(value.image)
		local place = get_place_in_inventory_from_index(index)
		image_draw_function(place.x, place.y, 3, 3)-- scale = 3, maybe should make that nicer
	end

	do
		love.graphics.setColor(0.7, 1, 1, 0.25)
		local place = get_place_in_inventory_from_index(selected)
		love.graphics.rectangle("line", place.x , place.y, slot_size, slot_size)
		love.graphics.setColor(prev_r,prev_g,prev_b)
	end

	if love.mouse.getX() > start_of_sidebar then
		local tmp_index_selected = get_index_from_mouse()
		local place = get_place_in_inventory_from_index(tmp_index_selected)
		if ordered_clues[tmp_index_selected] then
			love.graphics.printf(ordered_clues[tmp_index_selected].description, start_of_sidebar-200, place.y, 200)
		end
	end
	love.graphics.print(string.format("%05.2f", control_panel.info_share.get_game_info("clock")()),
    start_of_sidebar + 100, window_initial_height - 100)

	love.graphics.print("fps "..love.timer.getFPS(), start_of_sidebar + 100, window_initial_height - 80)
end

local function draw_minimap()
	local prev_r,prev_g,prev_b = love.graphics.getColor()
	local map_size = control_panel.info_share.get_game_info("map_size")()
	local player_position = control_panel.info_share.game_info.detective_position()
	local scale = minimap_size/map_size

	love.graphics.setColor(0,0,0)
	love.graphics.rectangle("fill", start_of_sidebar, window_initial_height - minimap_size, minimap_size, minimap_size)
	love.graphics.setColor(0.7, 1, 1, 0.25)
	love.graphics.rectangle("line", start_of_sidebar, window_initial_height - minimap_size, minimap_size, minimap_size)

	love.graphics.setColor(0, 0, 0.5) --river
	for _,val in ipairs(control_panel.info_share.game_info.river_parts() or {}) do
		love.graphics.rectangle("fill", start_of_sidebar + ( val.x-1 )*scale, window_initial_height - minimap_size + ( val.y-1 )*scale,
			scale, scale)
	end

	local police_car = control_panel.info_share.game_info.obstacle_lookup("police_car")
	local car_norm_x = math.min(math.max(police_car[1], 1), map_size)
	local car_norm_y = math.min(math.max(police_car[2], 1), map_size)
	love.graphics.setColor(1, 0, 0)
	love.graphics.rectangle("fill", start_of_sidebar + ( car_norm_x-1 )*scale,
		window_initial_height - minimap_size + ( car_norm_y-1 )*scale, scale, scale)

	love.graphics.setColor(0.2, 0.5, 0) --player
	love.graphics.rectangle("fill", start_of_sidebar + (player_position.x - 1)*scale,
		window_initial_height - minimap_size + (player_position.y - 1)*scale, scale, scale)

	love.graphics.setColor(prev_r, prev_g, prev_b)
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
