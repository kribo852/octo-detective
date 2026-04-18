local game_state_engine
local menu
local ingame -- a hack to remember, had to declare the variables here, so that they are visible to all functions, but had to set the filter mode before images were loaded (at definition)

function love.load()
	love.graphics.setDefaultFilter("nearest")
	love.graphics.setBackgroundColor( 0.0, 0.375, 0.250 )
	love.window.setTitle("octo-detective")

	game_state_engine = require "game_state_engine.game_state_engine"
	menu = require "game_states.menu"
	ingame = require "game_states.ingame.ingame"
	level_selector = require "game_states.ingame.level_selector"
	debounce_keyboard = require "game_states.debounced_keyboard"
	weather = require "weather"
	menu_view_controls = require "game_states.menu_view_controls"

	init_game_state_transitions()

	cur_level = "levels/map1.lua"
end

function init_game_state_transitions()
	game_state_engine.register_state("menu", menu.update, menu.draw)
	game_state_engine.register_update_arguments("menu", {"to_level_selector_state", "to_view_controls"})
	game_state_engine.register_draw_arguments("menu", {})

	game_state_engine.register_state("ingame", ingame.update, ingame.draw, ingame.init)
	game_state_engine.register_update_arguments("ingame", {"to_menu_state"})
	game_state_engine.register_draw_arguments("ingame", {})

	game_state_engine.register_state("level_selector", level_selector.update, level_selector.draw)
	game_state_engine.register_update_arguments("level_selector", {"to_game_state"})
	game_state_engine.register_draw_arguments("level_selector", {})

	game_state_engine.register_state("view_controls", menu_view_controls.update, menu_view_controls.draw)
	game_state_engine.register_update_arguments("view_controls", {"to_menu_state"})
	game_state_engine.register_draw_arguments("view_controls", {})

	game_state_engine.init("menu") --start in a menu state
end

function love.update(delta_time)
	game_state_engine.update(delta_time,
		{
		  to_game_state = to_game_state,
		  to_menu_state = to_menu_state, 
		  to_level_selector_state = to_level_selector_state,
		  to_view_controls = to_state_meta_creator("view_controls")
		}
	)
	debounce_keyboard.update()
	weather.update()
end

function love.draw()
	game_state_engine.draw({})
	weather.draw()
end

function to_game_state()
	game_state_engine.set_next_state("ingame")
end

function to_menu_state()
	game_state_engine.set_next_state("menu")
end

function to_level_selector_state()
	game_state_engine.set_next_state("level_selector")
end

function to_state_meta_creator(state)
	return function()
		game_state_engine.set_next_state(state)
	end
end
