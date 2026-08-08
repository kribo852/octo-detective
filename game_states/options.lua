local options = {
	mouse_pointer = require "game_states.mouse_pointer",
	meta_menu = require "game_states.meta_menu",
	info_share = require "info_share"
}

function options.update(delta_time, transition_to_next_state)
	if debounce_keyboard.check("escape") then
		transition_to_next_state()
	end

	local menu_obj = options.meta_menu.get_menu_layout({
		{type = "text", value = "Menu"},
		{type = "button", value = "Return", action=function() transition_to_next_state() end},
		{type = "button", value = "Music", action=function() options.info_share.push_to_channel("music_chnl", true) end},
		{type = "button", value = "No music", action=function() options.info_share.push_to_channel("music_chnl", false) end}
	})

	menu_obj.update()

end

function options.draw()
	local menu_obj = options.meta_menu.get_menu_layout({
		{type = "text", value = "Menu"},
		{type = "button", value = "Return"},
		{type = "button", value = "Music"},
		{type = "button", value = "No music"}
	})

	menu_obj.draw()
	options.mouse_pointer.draw()
end

return options