local info_share = {
	game_info = {},
	meta_info = {}
}

function info_share.register_meta_info(key, lookup_function_value)
	if type(lookup_function_value) ~= "function" then
		error("only functions are allowed to share values")
	end

	info_share.meta_info[key] = lookup_function_value
end

function info_share.register_game_info(key, lookup_function_value)
	if type(lookup_function_value) ~= "function" then
		error("only functions are allowed to share values")
	end

	info_share.game_info[key] = lookup_function_value
end

function info_share.get_game_info(key)
	return info_share.game_info[key] or function() return nil end
end

function info_share.clear()
	info_share.game_info = {}
	info_share.meta_info = {}
end

return info_share
