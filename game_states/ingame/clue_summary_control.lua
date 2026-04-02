
local clue_summary_control = {slot_size=60, spacing_x=50, selected=0}
local slot_size=60
local spacing_x=50
local selected=0


function clue_summary_control.check_for_clue_clicked()
  -- check where the player clicked, in the menu
  if love.mouse.isDown(1) then
     if love.mouse.getY() < slot_size then
     	selected = math.floor((love.mouse.getX() - spacing_x)/slot_size)
     end
  end
end

function clue_summary_control.draw(discovered_clues, image_getter)
	local prev_r,prev_g,prev_b = love.graphics.getColor()
	love.graphics.setColor(1, 1, 1, 0.1)
	love.graphics.rectangle("fill", spacing_x, 0, love.graphics.getWidth()-100, slot_size)
	love.graphics.setColor(prev_r,prev_g,prev_b)

	--in this function, we don't care about the origin
	
	for index,clue_name in discovered_clues do --ingame.clue_handler.get_discovered_summary()
		local image = image_getter(clue_name)
		local scale = slot_size/image:getWidth()-- square images only
		love.graphics.draw(image, spacing_x+(index-1)*slot_size, 0, 0, scale, scale)
	end

	love.graphics.setColor(0.7, 1, 1, 0.25)

	love.graphics.rectangle("line", spacing_x+slot_size*selected, 0, slot_size, slot_size)

	love.graphics.setColor(prev_r,prev_g,prev_b)
end

return clue_summary_control
