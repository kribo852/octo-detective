local between_states = {}

function between_states.draw() 
	 
end

function between_states.update(delta_time, transition_game_state)
	if not love.keyboard.isDown("escape") then
		transition_game_state()
	end  
end

return between_states