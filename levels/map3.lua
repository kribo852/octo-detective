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
	type = "tent",
	position = {x = 26, y = 3}
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
	name = "shoeprints1",
	type = "object",
	is_discovered = false,
	carried = false,
	image = "footsteps_down.png",
	description = "Mysterious shoeprints...\nI wonder where they lead",
	depends_on = none(),
	discovery_positions = { {23, 7} }
}
make_clue {
	name = "shoeprints2",
	type = "object",
	is_discovered = false,
	carried = false,
	image = "footsteps_down.png",
	description = "More shoeprints",
	depends_on = one("shoeprints1"),
	discovery_positions = { {22, 15} }
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
	discovery_positions = { {26, 4} }
}
make_clue {
	name = "victim",
	type = "body",
	is_discovered = false,
	carried = false,
	image = "drowned_body.png",
	description = "Drowned...\nThe clothes seems ragged, is she the woman name<disappeared> that lived in the tent camp?\nThe shoeprints that i found doesn't seem to match her shoes, they are too large.",
	depends_on = one("shoeprints1"),
	discovery_positions = { {21, 25} }
}
make_clue {
	name = "stash",
	type = "object",
	is_discovered = false,
	carried = true,
	image = "box_container.png",
	description = "This box looks apart, where can it have come from? Maybe I can call in to the station and see if it has been reported stolen",
	depends_on = none(),
	discovery_positions = { {4, 34} }
}
make_clue {
	name = "break_in",
	type = "event",
	is_discovered = false,
	carried = true,
	image = "call_police_station.png",
	description = "Three persons have been arrested for a break in where a box of jewelry was stolen. The jewelry has not yet been found.",
	depends_on = one("stash"),
	discovery_around = around("police_car")
}
make_clue {
	name = "jewelry",
	type = "object",
	is_discovered = false,
	carried = true,
	image = "jewelry.png",
	description = "Here is a piece of jewelry, this must be from the break in. The jewelry must be worth a large sum of money.",
	depends_on = all("victim", "break_in"),
	discovery_positions = { {10, 4} }
}
make_clue {
	name = "name<thief>",
	type = "person",
	is_discovered = false,
	carried = true,
	is_murderer = true,
	image = "portrait.png",
	display_on_ground_image = "call_police_station.png",
	description = "name<thief>, arrested for the break in, has a pair of shoes matching the shoeprints that I found near the camp.",
	depends_on = all("jewelry"),
	discovery_around = around("police_car")
}
