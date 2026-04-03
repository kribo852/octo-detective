set_size {
	size = 20
}
set_detective {
	position = {x = 1, y = 20},
}
set_police_car {
	position = {x = -1, y = 19}
}
make_clue {
	name = "ring",
	type = "object",
	is_discovered = false,
	carried = true,
	image = "ring.png",
	description = "A ring found in the woods, maybe connected to the crime, I should get it analyzed for fingerprints.",
	depends_on = none(),
	discovery_positions = { {5, 5} }
}
make_clue {
	name = "victim",
	type = "body",
	is_discovered = false,
	carried = false,
	image = "dead_body.png",
	description = "How gruesome, the body of a young woman. I must bring her justice and arrest her murderer.",
	depends_on = none(),
	discovery_positions = { {15, 15} }
}
make_clue {
	name = "wallet",
	type = "object",
	is_discovered = false,
	carried = true,
	image = "wallet.png",
	description = "This wallet contains a photo of a couple, a credit card and an adress. The woman in the picture is the victim. The credit card belongs to the person name<victim>",
	depends_on = one("victim"),
	discovery_positions = { {19, 2} }
}
make_clue {
	name="suspect",
	type="criminal profile",
	is_discovered = false,
	carried = false,
	image = "suspect.png",
	description = "A picture of the perpetrator emerges, who is name<victim>'s husband?\nI should go back to the police car and make a call to the station.",
	depends_on = all("wallet", "ring"),
	discovery_wait = 10 --in seconds, this is not implemented
}
make_clue {
	name = "name<murderer>",
	type = "person",
	is_murderer = true,
	is_discovered = false,
	carried = true, -- this is a little bit misleading, carried here means that the icon on the ground disappears, when the clue is discovered
	image = "suspect.png",
	description = "name<murderer> is the husband of the victim name<victim>, says the officer at the police station.",
	depends_on = one("suspect"),
	display_on_ground_image = "call_police_station.png",
	discovery_positions = { {-2, 19},{0, 19},{-1, 18},{-1, 20} }
}
