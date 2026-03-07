mapreader.set_size{
	size=35
}
mapreader.make_clue{
	name="ring",
	type="object",
	is_discovered=false,
	carried = true,
	image="ring.png",
	description = "description",
	dependency = {},
	action = { position = {5, 5} }
}

mapreader.make_clue{
	name="victim",
	type="body",
	is_discovered = false,
	carried = false,
	image = "dead_body.png",
	description="description",
	dependency = {},
	action = { position = {15, 15} }
}