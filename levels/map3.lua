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
make_clue {
	name = "footsteps",
	type = "object",
	is_discovered = false,
	carried = false,
	image = "footsteps_up.png",
	description = "Mysterious shoeprints, does not appear to match the victims shoes.",
	depends_on = one("victim"),
	discovery_positions = { {12, 7} }
}
make_clue {
	name = "victim",
	type = "body",
	is_discovered = false,
	carried = false,
	image = "drowned_body.png",
	description = "Drowned...\nThe clothes seems ragged, where did she come from?",
	depends_on = none(),
	discovery_positions = { {5, 14} }
}