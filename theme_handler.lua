local theme_handler = {
	themes = {
		opening="third_party_assets/Bones.mp3",
		victory="third_party_assets/Tempest.mp3"
	}
}

function theme_handler.play(theme)
	if theme_handler.audio_source and (theme_handler.audio_source:isPlaying() or theme_handler.is_paused) then
		return
	end

	theme_handler.audio_source = love.audio.newSource(theme_handler.themes[theme], "stream")
	theme_handler.audio_source:setVolume(0.25)

	love.audio.play(theme_handler.audio_source)
end

function theme_handler.continue_playing(boolean_value)
	if not boolean_value then
		theme_handler.audio_source:pause()
		theme_handler.is_paused = true
	else
		theme_handler.audio_source:play()
		theme_handler.is_paused = false
	end
end

return theme_handler