set_size{
	size = 35
}
set_detective {
	position = {x = 1, y = 36},
}
set_police_car {
	position = {x = -1, y = 35}
}
make_clue{
	name = "ring",
	type = "object",
	is_discovered = false,
	carried = true,
	image = "ring.png",
	description = "A ring found in the woods, maybe connected to the crime, I should get it analyzed for fingerprints",
	depends_on = none(),
	discovery_positions = { {5, 5} }
}
make_clue{
	name = "victim",
	type = "body",
	is_discovered = false,
	carried = false,
	image = "dead_body.png",
	description = "How gruesome, the body of a young woman. I must bring her justice and arrest her murderer",
	depends_on = none(),
	discovery_positions = { {15, 15} }
}
make_clue{
	name = "wallet",
	type = "object",
	is_discovered = false,
	carried = true,
	image = "wallet.png",
	description = "This wallet contains a photo of a couple and an adress. The woman in the picture is the victim.",
	depends_on = one("victim"),
	discovery_positions = { {25, 0} }
}
make_clue{
	name="suspect",
	type="person",
	is_discovered = false,
	carried = false,
	image = "suspect.png",
	description = "A picture of the perpetrator emerges, who is the the victims husband? \n I should go back to the police car and make a call to the station",
	depends_on = all("wallet", "ring"),
	discovery_wait = 10 --in seconds
}
make_clue{
	name = "Dan Wright",
	type = "Person",
	is_discovered = false,
	carried = true, 
	image = "suspect.png",
	description = "Dan Wright is the husband of the victim Isabella, says the registers at the police station",
	depends_on = one("suspect"),
	display_on_ground_image = "call_police_station.png",
	discovery_positions = { {-2, 35},{0, 35},{-1, 34},{-1, 36} }
}
