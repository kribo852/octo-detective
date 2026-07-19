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
	run = {
		{10, "clockwise"},
		{7, "counterclockwise"},
		{7, "clockwise"},
		{4, "counterclockwise"},
		{10, "counterclockwise"},
		{15, "crossing"},
		{1, "crossing"},
		{1, "crossing"}
	}
}
make_clue {
	name = "footsteps",
	type = "object",
	is_discovered = false,
	carried = false,
	image = "footsteps_down.png",
	description = "Mysterious shoeprints...",
	depends_on = none(),
	discovery_positions = { {23, 7} }
}
make_clue {
	name = "initial information",
	type = "object",
	is_discovered = false,
	carried = false,
	image = "call_police_station.png",
	description = "A call has come about a missing person. The caller said that he has not seen name<disappeared> in a week, name<disappeared> is homeless and lives in a tent camp in the woods.",
	depends_on = none()
}
make_clue {
	name = "empty_camp",
	type = "object",
	is_discovered = false,
	carried = true,
	image = "tent",
	display_on_ground_image = "blank_action.png",
	description = "The camp seems abandoned.",
	depends_on = none(),
	discovery_around = around("tent")
}
make_clue {
	name = "victim",
	type = "body",
	is_discovered = false,
	carried = false,
	image = "drowned_body.png",
	description = "Drowned...\nThe clothes seems ragged, is she the woman that lived in the tent camp?",
	depends_on = one("footsteps"),
	discovery_positions = { {21, 25} }
}
add_obstacle {
	type = "tent",
	position = {x = 27, y = 3}
}