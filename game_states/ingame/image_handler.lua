local world_img = love.graphics.newImage("objects.png")


local image_handler = {
	world_img = world_img,
	tree1 = love.graphics.newQuad(0, 0, 20, 20, world_img),
	tree2 = love.graphics.newQuad(40, 0, 20, 20, world_img),
	tree3 = love.graphics.newQuad(40, 20, 20, 20, world_img),
	tree4 = love.graphics.newQuad(60, 20, 20, 20, world_img),
	boulder = love.graphics.newQuad(60, 0, 20, 20, world_img),
	police_car = love.graphics.newQuad(40, 40, 20, 20, world_img),
	plants = love.graphics.newQuad(20, 0, 20, 20, world_img),
	grave = love.graphics.newQuad(20, 20, 20, 20, world_img)
}

return image_handler