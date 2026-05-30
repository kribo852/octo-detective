local theme_handler = {
	themes = {
		opening="third_party_assets/Bones.mp3",
		victory="third_party_assets/Tempest.mp3"
	}
}

function theme_handler.play(theme)
	if theme_handler.audio_source and theme_handler.audio_source:isPlaying() then
		return
	end

	theme_handler.audio_source = love.audio.newSource(theme_handler.themes[theme], "stream")
	theme_handler.audio_source:setVolume(0.25)

	love.audio.play(theme_handler.audio_source)
end

return theme_handler