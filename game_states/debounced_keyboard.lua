-- this functionality is sort of already built into LOVE 2D, the reason that i built my own is that the standard way can't 
--be reached in a nice way from the game states
local debounced_keyboard = { registered={} }

function debounced_keyboard.check(key)
	
	if love.keyboard.isDown(key) then
		if not debounced_keyboard.registered[key] then
			debounced_keyboard.registered[key] = true
			return true
		end
	end
	return false
end

function debounced_keyboard.update()
	for key,value in pairs(debounced_keyboard.registered) do
		if value then
			if not love.keyboard.isDown(key) then
				debounced_keyboard.registered[key] = false
			end
		end
	end
end

return debounced_keyboard
