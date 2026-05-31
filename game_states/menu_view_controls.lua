local menu_view_controls = {
	meta_menu = require "game_states.meta_menu"
}


function menu_view_controls.update(delta_time, transition_to_next_state)
	if debounce_keyboard.check("escape") then
		transition_to_next_state()
	end 
end


function menu_view_controls.draw()

	local menu_obj = menu_view_controls.meta_menu.get_menu_layout({
		{type = "text", value = "Controls."},
		{type = "text", value = "Use up, down, left and right arrows to move around the crime scene."},
		{type = "text", value = "Use the space key to discover clues."},
		{type = "text", value = "Use the mouse cursor and button 1 to select items in the summary."},
		{type = "text", value = "Particulary to select a suspect for arrestation,"},
		{type = "text", value = "which can be done at the police car."},
		{type = "text", value = "Press esc to exit menu"}
	})

	menu_obj.draw()

end


return menu_view_controls