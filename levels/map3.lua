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
	run = { {10, "clockwise"}, {7, "counterclockwise"}, {10, "clockwise"}, {5, "crossing"}, {2, "counterclockwise"}, {10, "counterclockwise"}, {15, "crossing"} }
}