local game_state_engine = {}

function game_state_engine.init(initialstate)
	game_state_engine.state = "no state yet" -- set this to empty, so that the update can run a transition
	game_state_engine.next_state = initialstate 
end

function game_state_engine.register_state(state, update_func, draw_func, load_func, teardown_func) -- load or teardown?
	load_func = load_func or function() end
	teardown_func = teardown_func or function() end

	game_state_engine[state] = {update_func = update_func, draw_func = draw_func, load_func=load_func, teardown_func=teardown_func}
end

function game_state_engine.register_update_arguments(state, array_argument_names)
	game_state_engine[state].update_arguments = array_argument_names -- set the arguments in order
end

function game_state_engine.register_draw_arguments(state, array_argument_names)
	game_state_engine[state].draw_arguments = array_argument_names -- set the arguments in order
end

function game_state_engine.draw(argument_lookup_table)
	local curr_state = game_state_engine.state

	game_state_engine[curr_state]
	.draw_func(unpack(game_state_engine.make_arguments(
		game_state_engine[curr_state].draw_arguments, argument_lookup_table))
	)
end

--[=[
to make this generic, in this file we dont know what the arguments are, they are just passed
throught the argument_lookup_table, then the update function of the state is called with 
delta time, and then the correct arguments
]=]--
function game_state_engine.update(delta_time, argument_lookup_table)
	if game_state_engine.state ~= game_state_engine.next_state then
		if(game_state_engine[game_state_engine.state] and game_state_engine[game_state_engine.state].teardown_func) then
			game_state_engine[game_state_engine.state].teardown_func() --tear down
		end
		game_state_engine.state = game_state_engine.next_state
		print("state"..game_state_engine.state)
		game_state_engine[game_state_engine.state].load_func()--transition loading here
	end	


	local curr_state = game_state_engine.state

	game_state_engine[curr_state]
	.update_func(delta_time, unpack(game_state_engine.make_arguments(
		game_state_engine[curr_state].update_arguments, argument_lookup_table))
	)
end

function game_state_engine.make_arguments(array_argument_names, argument_lookup_table)
	local rtn = {}
	for i=1,#array_argument_names do
		table.insert(rtn, argument_lookup_table[array_argument_names[i]])
	end
	return rtn
end

function game_state_engine.set_next_state(state)
	game_state_engine.next_state = state
end

return game_state_engine
