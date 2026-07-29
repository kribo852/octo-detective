local autoexpand_metatable = {
	__index = function(tab, key)
    	tab[key] = {}
    	return tab[key]
	end
}

local noise_generator = {

}

function noise_generator.new_random_func(scale)
		local cache_randoms = {}
		local cache_smooth_summed_randoms = {}

		setmetatable(cache_randoms, autoexpand_metatable)
		setmetatable(cache_smooth_summed_randoms, autoexpand_metatable)

		local random_for_position = function(x, y)
			if not cache_randoms[x][y] then
				cache_randoms[x][y] = love.math.random() -- this is just to store the random values, so that repeated lookup gives the same value again
			end
			return cache_randoms[x][y]
		end

		local smooth_random = function (x, y)
			scale = scale or 2

			if not cache_smooth_summed_randoms[x][y] then
				local sum = 0
				local no_of_entries = (2*scale+1)^2

				for i=-scale,scale do
					for j=-scale,scale do
						sum = sum + random_for_position(x+i, y+j)
					end
				end
				cache_smooth_summed_randoms[x][y] = sum / no_of_entries
			end
			return cache_smooth_summed_randoms[x][y]
		end

	return {
		smooth_random=smooth_random
	}
end

return noise_generator
