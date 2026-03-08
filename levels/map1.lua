set_size{
	size=35
}
set_detective {
	position = {x = 1, y = 36}
}
make_clue{
	name="ring",
	type="object",
	is_discovered=false,
	carried = true,
	image="ring.png",
	description = "A ring found in the woods, maybe connected to the crime, I should get it analyzed for fingerprints",
	dependency = {},
	action = { position = {5, 5} }
}

make_clue{
	name="victim",
	type="body",
	is_discovered = false,
	carried = false,
	image = "dead_body.png",
	description="How gruesome, the body of a young woman. I must bring her justice and arrest her murderer",
	dependency = {},
	action = { position = {15, 15} }
}
