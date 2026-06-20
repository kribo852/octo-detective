set_size {
	size = 35
}
set_detective {
	position = {x = 1, y = 20},
}
add_obstacle {
	type = "police_car",
	position = {x = -1, y = 19}
}
add_river {
	x0_y = 15,
	run = { {"clockwise", 10}, {"counterclockwise", 7}, {"clockwise", 10}, {"crossing", 5}, {"counterclockwise", 2}, {"counterclockwise", 10} }
}