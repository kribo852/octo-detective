local info_meta_table = {
    __index = function(t, key)
        return function() return nil end
    end
}

local info_share = { 
	info_channels = {}
}

function info_share.clear()
	info_share.game_info = {}
	info_share.meta_info = {}
	setmetatable(info_share.game_info, info_meta_table)
	setmetatable(info_share.meta_info, info_meta_table)
end

info_share.clear()

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

function info_share.register_consumers_for_channel(channel, consumer)

	if not info_share.info_channels[channel] then
		info_share.info_channels[channel] = {}
	end

	table.insert(info_share.info_channels[channel], consumer)
end

function info_share.push_to_channel(channel, value)
	if not info_share.info_channels[channel] then
		return
	end

	for _,consumer in ipairs(info_share.info_channels[channel]) do
		consumer(value)
	end
end

return info_share
