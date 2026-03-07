local game_state_engine
local menu
local ingame -- a hack to remember, had to declare the variables here, so that they ar visible to all functions, but had to set the filter mode before images were loaded (at definition)

function love.load()
	love.graphics.setDefaultFilter("nearest")
	love.graphics.setBackgroundColor( 0, 0.05, 0.05 )
	love.window.setTitle("octo-detective")

	game_state_engine = require "game_state_engine.game_state_engine"
	menu = require "game_states.menu"
	ingame = require "game_states.ingame.ingame"

	init_game_state_transitions()	
end

function init_game_state_transitions()
	game_state_engine.register_state("menu", menu.update, menu.draw)
	game_state_engine.register_update_arguments("menu", {"transition_game_state"})
	game_state_engine.register_draw_arguments("menu", {})

	game_state_engine.register_state("ingame", ingame.update, ingame.draw, ingame.init)
	game_state_engine.register_update_arguments("ingame", {"transition_to_menu_state"})
	game_state_engine.register_draw_arguments("ingame", {})

	local to_menu = require "game_states.between_states"

	game_state_engine.register_state("transition_to_menu", to_menu.update, to_menu.draw)
	game_state_engine.register_update_arguments("transition_to_menu", {"to_menu_state"})
	game_state_engine.register_draw_arguments("transition_to_menu", {})

	game_state_engine.init("menu") --start in a menu state
end

function love.update(delta_time) 
	game_state_engine.update(delta_time, 
		{ 
		  transition_game_state=transition_to_game_state, 
		  transition_to_menu_state=transition_to_menu_state,
		  to_menu_state=to_menu_state
		}
	)
end


function love.draw()
	game_state_engine.draw({})
end

function transition_to_game_state()
 	game_state_engine.set_next_state("ingame") 
end	

function transition_to_menu_state()
 	game_state_engine.set_next_state("transition_to_menu") 
end	

function to_menu_state()
 	game_state_engine.set_next_state("menu") 
end	