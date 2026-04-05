local square_size = 60 

local calc_start = function(det_x, det_y, x, y, centered_origin)
	local screen_w_center = love.graphics.getWidth()/2
	local screen_h_center = love.graphics.getHeight()/2

	local rtn_x = (x-det_x)*square_size + screen_w_center
	local rtn_y = (y-det_y)*square_size + screen_h_center

	if not centered_origin then
		rtn_x = rtn_x - square_size/2
		rtn_y = rtn_y - square_size/2
	end
	
	return rtn_x,rtn_y
end

local calc_end = function(det_x, det_y, x, y) 
	local start_x, start_y = calc_start(det_x, det_y, x, y) 

	return start_x+square_size-1, start_y+square_size-1
end

return {
	calc_start=calc_start,
	calc_end=calc_end
}