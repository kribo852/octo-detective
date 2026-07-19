local world_img = love.graphics.newImage("assets/objects.png")

local image_handler = {
	tree1 = love.graphics.newQuad(0, 0, 20, 20, world_img),
	tree2 = love.graphics.newQuad(40, 0, 20, 20, world_img),
	tree3 = love.graphics.newQuad(40, 20, 20, 20, world_img),
	tree4 = love.graphics.newQuad(60, 20, 20, 20, world_img),
	tree5 = love.graphics.newQuad(80, 0, 20, 20, world_img),
	boulder = love.graphics.newQuad(60, 0, 20, 20, world_img),
	police_car = love.graphics.newQuad(40, 40, 20, 20, world_img),
	plants = love.graphics.newQuad(20, 0, 20, 20, world_img),
	grave = love.graphics.newQuad(20, 20, 20, 20, world_img),
	crossing_stones = love.graphics.newQuad(20, 40, 20, 20, world_img),
	tent = love.graphics.newQuad(60, 40, 20, 20, world_img)
}


function image_handler.get_new_mutable_image_map()
	local other_images = {

	}

	return {
		get_draw_function = function(sprite_name)
			local sprite_quad_from_default = image_handler[sprite_name]

			if not sprite_quad_from_default then
				if not other_images[sprite_name] then
					local image = love.graphics.newImage("assets/"..sprite_name)
					local quad = love.graphics.newQuad(0, 0, image:getWidth(), image:getHeight(), image)
					other_images[sprite_name] = {image=image, quad=quad}
					print("loaded a new sprite to the store: "..sprite_name)
				end
				return function(x, y, scale_x, scale_y) love.graphics.draw(other_images[sprite_name].image, other_images[sprite_name].quad, x, y, 0, scale_x, scale_y) end
			end

			return function(x, y, scale_x, scale_y) love.graphics.draw(world_img, sprite_quad_from_default, x, y, 0, scale_x, scale_y) end
		end
	}
end

return image_handler
