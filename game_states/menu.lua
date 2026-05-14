local menu = {
	mouse_pointer = require "game_states.mouse_pointer",
	meta_menu = require "game_states.meta_menu",
	theme_handler = require "theme_handler"
}

function menu.draw() 
	local menu_obj = menu.meta_menu.get_menu_layout({
		{type = "text", value = "Menu"},
		{type = "button", value = "Start a new investigation"},
		{type = "button", value = "View controls"},
		{type = "button", value = "Quit"}})

	menu_obj.draw()
	menu.mouse_pointer.draw()
end

function menu.update(delta_time, transition_to_forward_state, transition_to_controls)
	if debounce_keyboard.check("escape") then
		love.event.quit(0)
	end

	menu.theme_handler.play()

	local menu_obj = menu.meta_menu.get_menu_layout({
		{type = "text", value = "Menu"},
		{type = "button", value = "Start a new investigation", action=function() transition_to_forward_state() end},
		{type = "button", value = "View controls", action=function() transition_to_controls() end},
		{type = "button", value = "Quit", action=function() love.event.quit(0) end}
	})

	menu_obj.update()
end

return menu
