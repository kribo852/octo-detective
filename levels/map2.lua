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
	description = "A skeleton. I must find out who this person was",
	depends_on = none(),
	discovery_positions = { {20, 10} }
}
make_clue {
	name = "disappeared",
	type = "body",
	is_discovered = false,
	carried = true,
	image = "suspect.png",--have to rename this image, the naming isn't correct in this case 
	description = "The person name<disappeared> disappeared a few months ago, and hasn't been seen, the skeletal remains likely belongs to name<disappeared>",
	display_on_ground_image = "call_police_station.png",
	depends_on = one("skeleton"),
	discovery_around = around("police_car")
}
make_clue {
	name = "name<witness>",
	type = "person",
	is_murderer = false,
	is_discovered = false,
	carried = true,
	image = "person.png",
	description = "This person name<witness> knew the disappeared person",
	depends_on = one("disappeared"),
	display_on_ground_image = "blank_action.png",
	discovery_around = around("name<witness>")
}
make_clue {
	name="grave1",
	type="grave",
	is_discovered = false,
	carried = true,
	image = "grave.png",
	display_on_ground_image = "blank_action.png",
	description = "These seems to be the graves of a family, in a small private cemetary",
	depends_on = none(),
	discovery_positions = { {5, 6} }
}
