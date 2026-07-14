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
	carried = false,
	image = "skeleton.png",
	description = "A skeleton, just as the caller said earlier, when calling the police station. I must find out who this person was.",
	depends_on = none(),
	discovery_positions = { {20, 10} }
}
make_clue {
	name = "disappeared",
	type = "body",
	is_discovered = false,
	carried = true,
	image = "portrait.png",
	description = "The person name<disappeared> disappeared a few months ago, and hasn't been seen, the skeletal remains likely belongs to name<disappeared>",
	display_on_ground_image = "call_police_station.png",
	depends_on = one("skeleton"),
	discovery_around = around("police_car")
}
make_clue {
	name = "witness",
	type = "person",
	is_murderer = false,
	is_discovered = false,
	carried = true,
	image = "person.png",
	description = "This person name<witness> knew the disappeared person name<disappeared>. name<disappeared> was a gardener at the name<family> manor",
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
make_clue {
	name="grave2",
	type="grave",
	is_discovered = false,
	carried = true,
	image = "grave.png",
	display_on_ground_image = "blank_action.png",
	description = "The graves belong to the name<family> family",
	depends_on = all("witness", "grave1"),
	discovery_positions = { {7, 6} }
}
make_clue {
	name="grave3",
	type="grave",
	is_discovered = false,
	carried = true,
	image = "grave.png",
	display_on_ground_image = "blank_action.png",
	description = "This person, the son in the family, name<son> died a year ago, quite young. What can they tell me from the police station about the family? I Better call them from the car.",
	depends_on = one("grave2"),
	discovery_positions = { {9, 6} }
}
make_clue {
	name="daughter",
	type="person",
	is_murderer = true,
	is_discovered = false,
	carried = true,
	image = "portrait2.png",
	display_on_ground_image = "call_police_station.png",
	description = "The only now living member of the family is name<daughter> name<family>. She inherited the family fortune.",
	depends_on = one("grave3"),
	discovery_around = around("police_car")
}
make_clue {
	name="diary",
	type="book",
	is_discovered = false,
	carried = true,
	image = "book.png",
	description = "Seems to be a book belonging to name<disappeared>. This page has written on it: I saw name<daughter> picking the poisonous mushrooms, and later that week name<son> died. I think name<daughter> poisoned her brother to get the whole heritage. I will confront name<daughter> tomorrow",
	depends_on = one("daughter"),
	discovery_positions = { {20, 20} }
}
make_clue {
	name="suspect",
	type="criminal profile",
	is_discovered = false,
	carried = false,
	image = "suspect.png",
	description = "Hmm, name<disappeared> sees name<daughter> pick poisonous mushrooms, and then name<son> dies. name<disappeared> confronts name<daughter> with this and some time later he disappears. name<daughter> inherites the family fortune. It looks like I must make another call to the station",
	depends_on = all("diary"),
	discovery_wait = 10 --in seconds, this is not implemented
}
