extends AudioStreamPlayer

var volume = 70

func _ready() -> void:
	connect("finished", func(): stream_paused = false)

func play_music(music: AudioStream):
	stream = music
	play()

func play_sound(sound: AudioStream, randomness: float = 0):
	var player = AudioStreamPlayer.new()
	player.pitch_scale = randf_range(1 - randomness, 1 + randomness)
	player.stream = sound
	player.connect("finished", player.queue_free)
	add_child(player)
	player.play()

func set_volume(value: float):
	volume = clamp(value, 0, 1)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(volume))

func set_music_volume(value: float):
	volume = clamp(value, 0, 1)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(volume))
