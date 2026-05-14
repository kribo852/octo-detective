local theme_handler = {}

function theme_handler.play()
	if theme_handler.audio_source and theme_handler.audio_source:isPlaying() then
		return
	end

	theme_handler.audio_source = love.audio.newSource("assets/Bones.mp3", "stream")
	theme_handler.audio_source:setVolume(0.25)

	love.audio.play(theme_handler.audio_source)
end

return theme_handler