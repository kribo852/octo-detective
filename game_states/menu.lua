local menu = {
	mouse_pointer = require "game_states.mouse_pointer"
}

function menu.draw() 
	love.graphics.print("Menu", 300, 100, 0, 1.5)
	love.graphics.print("Start new game", 300, 200, 0, 1.5)
	love.graphics.print("Quit", 300, 300, 0, 1.5)
	menu.mouse_pointer.draw()
end

function menu.update(delta_time, transition_to_forward_state)
	if love.keyboard.isDown("escape") then
		love.event.quit(0)
	end 
	menu.clicked({minx=300, maxx=400, miny=300, maxy=320, click=function() love.event.quit(0) end})

	menu.clicked({minx=300, maxx=400, miny=200, maxy=220, click=function() transition_to_forward_state() end})
end

function menu.clicked(button) 
	if love.mouse.getX() > button.minx and
	   love.mouse.getX() < button.maxx and
	   love.mouse.getY() > button.miny and
	   love.mouse.getY() < button.maxy then
	   	if love.mouse.isDown(1) then
	   		button.click()
	   	end
	end
end

return menu
