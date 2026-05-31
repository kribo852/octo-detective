local meta_menu = {
	start_y = 100,
	start_x = 250,
	start_x_long_text = 100,
	end_x_cut = 500,
	end_x_cut_long = 650,
	mouse_debounce_click = true,
	next_item_offset = 50,
	intro_screen = love.graphics.newImage("office.png")
}

local function inside_button(start_x, start_y)
	if love.mouse.getX() > start_x and
	   love.mouse.getX() < start_x + meta_menu.end_x_cut and
	   love.mouse.getY() > start_y and
	   love.mouse.getY() < start_y + meta_menu.next_item_offset then
	   return true	
	end
	return false
end

local function meta_draw(elements)
	return function()
		local prev_red, prev_green, prev_blue, prev_alpha = love.graphics.getColor()
		love.graphics.setColor(0.5, 0.5, 0.5)
		love.graphics.draw(meta_menu.intro_screen, 0, 0, 0, window_initial_width/meta_menu.intro_screen:getWidth(), window_initial_height/meta_menu.intro_screen:getHeight())

		for index,element in ipairs(elements) do
			local type = element.type
			love.graphics.setColor(1.0, 1.0, 1.0) -- draw white text
			if type == "text" then
				if #element.value > 50 then
					love.graphics.printf(element.value, meta_menu.start_x_long_text , meta_menu.start_y + meta_menu.next_item_offset * (index - 1), meta_menu.end_x_cut_long, "left", 0, 1.5)
				else
					love.graphics.printf(element.value, meta_menu.start_x , meta_menu.start_y + meta_menu.next_item_offset * (index - 1), meta_menu.end_x_cut, "left", 0, 1.5)
				end
			end
			if type == "button" then
				love.graphics.setColor(0.1, 0.1, 1.0, 0.75) --draw the surrounding box first, with some transparency
				if inside_button(meta_menu.start_x, meta_menu.start_y + meta_menu.next_item_offset * (index - 1)) then
					love.graphics.rectangle("fill", meta_menu.start_x, meta_menu.start_y + meta_menu.next_item_offset * (index - 1), meta_menu.end_x_cut, meta_menu.next_item_offset, 5, 5)
				end
				love.graphics.setColor(1.0, 1.0, 1.0) -- draw white text for a button
				love.graphics.printf(element.value, meta_menu.start_x, meta_menu.start_y + meta_menu.next_item_offset * (index - 1), meta_menu.end_x_cut, "left", 0, 1.5)
			end
		end
		love.graphics.setColor(prev_red, prev_green, prev_blue, prev_alpha)
	end
end

local function meta_update(elements)
	return function()
		if not love.mouse.isDown(1) then
			meta_menu.mouse_debounce_click = true
		end
		for index,element in ipairs(elements) do
			local type = element.type
			if type == "button" then
				if inside_button(meta_menu.start_x, meta_menu.start_y + meta_menu.next_item_offset * (index - 1)) then
					if love.mouse.isDown(1) and meta_menu.mouse_debounce_click then
	   					meta_menu.mouse_debounce_click = false
	   					element.action()
	   				end
				end
			end
		end
	end
end

function meta_menu.get_menu_layout(elements)
	return { update=meta_update(elements), draw=meta_draw(elements) }
end	

return meta_menu
