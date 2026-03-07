extends Node

const SETTINGS_FILE_PATH = "user://settings.cfg"

func save_settings(sfx_volume, music_volume):
	var config = ConfigFile.new()

	config.set_value("Audio", "SFXVolume", sfx_volume)
	config.set_value("Audio", "MusicVolume", music_volume)
	# config.set_value("Graphics", "WindowSize", window_size)

	AudioManager.set_volume(sfx_volume / 4.0 * 100)
	AudioManager.set_music_volume(music_volume / 4.0)

	var err = config.save(SETTINGS_FILE_PATH)
	if err != OK:
			print("failed to save settings: ", error_string(err))

func load_settings():
	var config = ConfigFile.new()
	var err = config.load(SETTINGS_FILE_PATH)
	# if err != OK:
	# 		print("failed to load settings: ", error_string(err))
	# 		return null

	var sfx_volume = config.get_value("Audio", "SFXVolume", 4.0)
	var music_volume = config.get_value("Audio", "MusicVolume", 4.0)

	AudioManager.set_volume(sfx_volume / 4.0)
	AudioManager.set_music_volume(music_volume / 4.0)

	return {
		"SFXVolume": sfx_volume,
		"MusicVolume": music_volume,
		# "WindowSize": window_size
	}
