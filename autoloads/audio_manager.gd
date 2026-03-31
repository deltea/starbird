extends AudioStreamPlayer

@export_category("Music")
@export var music_stream: AudioStream

var dash: AudioStream = preload("res://assets/audio/sfx/dash.wav")
var land: AudioStream = preload("res://assets/audio/sfx/land.wav")
var bouncepad: AudioStream = preload("res://assets/audio/sfx/bouncepad.wav")
var select: AudioStream = preload("res://assets/audio/sfx/select.wav")
var star: AudioStream = preload("res://assets/audio/sfx/star.wav")
var enter_level: AudioStream = preload("res://assets/audio/sfx/enter_level.wav")
var countdown_blip: AudioStream = preload("res://assets/audio/sfx/countdown_blip.wav")
var countdown_start: AudioStream = preload("res://assets/audio/sfx/countdown_start.wav")
var breakable: AudioStream = preload("res://assets/audio/sfx/breakable.wav")
var goal: AudioStream = preload("res://assets/audio/sfx/goal.wav")
var blip: AudioStream = preload("res://assets/audio/sfx/blip.wav")
var locked: AudioStream = preload("res://assets/audio/sfx/locked.wav")

var sfx_volume = 1
var music_volume = 1

func _ready() -> void:
	connect("finished", func(): stream_paused = false)
	play_music(music_stream)

func play_music(music: AudioStream):
	stream = music
	play()

func play_sound(sound: AudioStream, randomness: float = 0):
	var player = AudioStreamPlayer.new()
	player.pitch_scale = randf_range(1 - randomness, 1 + randomness)
	player.stream = sound
	player.bus = "SFX"
	player.connect("finished", player.queue_free)
	add_child(player)
	player.play()

func set_sfx_volume(value: float):
	sfx_volume = clamp(value, 0, 1)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(sfx_volume))

func set_music_volume(value: float):
	music_volume = clamp(value, 0, 1)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(music_volume))
