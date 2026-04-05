local name_generator = {

}

function name_generator.make_person_name_function()
	local length = 7
	local end_f = function(nam_gen_func, accumulated)
		print(nam_gen_func)
		if #accumulated >= length then 
			return accumulated
		end
		return nam_gen_func(accumulated)
	end


	return function()
		local vowels = {"e","y","u","i","o","a"}
		local consonants = {"q","w","r","t","p","s","d","f","g","h","j","j","k","l","z","x","c","v","b","n","m"}

		local v1 = function() return "" end
		local v2 = function() return "" end
		local c1 = function() return "" end
		local c2 = function() return "" end


		v1 = function(accumulated)
			if love.math.random() < 0.5 then
				return end_f(v2, accumulated..vowels[love.math.random(1, #vowels)])
			else
				return end_f(c1, accumulated..vowels[love.math.random(1, #vowels)])
			end
		end

		v2 = function(accumulated)
			return end_f(c1, accumulated..vowels[love.math.random(1, #vowels)])
		end

		c1 = function(accumulated)
			if love.math.random() < 0.5 then
				return end_f(c2, accumulated..consonants[love.math.random(1, #consonants)])
			else
				return end_f(v1, accumulated..consonants[love.math.random(1, #consonants)])
			end
		end

		c2 = function(accumulated)
			return end_f(v1, accumulated..consonants[love.math.random(1, #consonants)])
		end

		return c1("")
	end
end

function name_generator.reset()
	name_generator.stored_names = {}
end

function name_generator.replace_token_with_name(token)
	if not name_generator.stored_names["name_"..token] then
		name_generator.stored_names["name_"..token] = name_generator.make_person_name_function()():gsub("^%l", string.upper)
	end

	return name_generator.stored_names["name_"..token]
end


return name_generator
