local menu_view_controls = {}


function menu_view_controls.update(delta_time, transition_to_next_state)
	if debounce_keyboard.check("escape") then
		transition_to_next_state()
	end 
end


function menu_view_controls.draw()
	love.graphics.printf("Controls. \n Use up, down, left and right arrows to move around the crime scene. Use the space key to discover clues. Use the mouse cursor and button 1 to select items "..
		"in the summary, praticulary to select a suspect for arrestation, which can be done at the police car.\n\nPress esc to exit menu", 100, 100, 400, "left", 0, 1.5)
end


return menu_view_controls