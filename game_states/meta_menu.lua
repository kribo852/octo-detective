local meta_menu = {
	start_y = 100,
	start_x = 250,
	start_x_long_text = 100,
	end_x_cut = 500,
	mouse_debounce_click = true
}

local function meta_draw(elements)
	return function()
		for index,element in ipairs(elements) do
			local type = element.type
			if type == "text" then
				if #element.value > 50 then
					love.graphics.printf(element.value, meta_menu.start_x_long_text , meta_menu.start_y + 25 * (index - 1), meta_menu.end_x_cut, "left", 0, 1.5)
				else
					love.graphics.printf(element.value, meta_menu.start_x , meta_menu.start_y + 25 * (index - 1), meta_menu.end_x_cut, "left", 0, 1.5)
				end
			end
			if type == "button" then
				love.graphics.printf(element.value, meta_menu.start_x, meta_menu.start_y + 25 * (index - 1), meta_menu.end_x_cut, "left", 0, 1.5)
			end
		end
	end
end

local function inside_and_left_click(start_x, start_y)
	if love.mouse.getX() > start_x and
	   love.mouse.getX() < start_x + meta_menu.end_x_cut and
	   love.mouse.getY() > start_y and
	   love.mouse.getY() < start_y + 25 then
	   	if love.mouse.isDown(1) and meta_menu.mouse_debounce_click then
	   		meta_menu.mouse_debounce_click = false
	   		return true
	   	end
	end
	return false
end

local function meta_update(elements)
	return function()
		if not love.mouse.isDown(1) then
			meta_menu.mouse_debounce_click = true
		end
		for index,element in ipairs(elements) do
			local type = element.type
			if type == "button" then
				if inside_and_left_click(meta_menu.start_x, meta_menu.start_y + 25 * (index - 1)) then
					element.action()
				end
			end
		end
	end
end

function meta_menu.get_menu_layout(elements)
	return { update=meta_update(elements), draw=meta_draw(elements) }
end	




return meta_menu
