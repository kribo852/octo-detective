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
add_obstacle {
	type = "grave",
	position = {x = 5, y = 5}
}
add_obstacle {
	type = "grave",
	position = {x = 7, y = 5}
}
add_obstacle {
	type = "grave",
	position = {x = 9, y = 5}
}
add_person {
	name = "name<witness>",
	type = "person",
	behaviour = "stroll",
	position = {x = 34, y = 20}
}
make_clue {
	name = "skeleton",
	type = "object",
	is_discovered = false,
	carried = true,
	image = "skeleton.png",
	description = "A skeleton.",
	depends_on = none(),
	discovery_positions = { {20, 10} }
}
make_clue {
	name = "name<witness>",
	type = "person",
	is_murderer = false,
	is_discovered = false,
	carried = true,
	image = "person.png",
	description = "This person name<witness> knew the disappeared person",
	depends_on = none(),
	display_on_ground_image = "blank_action.png",
	discovery_around = around("name<witness>")
}
