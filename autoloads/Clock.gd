extends Node

@export var slowmo_smoothing = 0.04

var time = 0.0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _process(dt: float) -> void:
	time += dt

func wait(duration: float):
	await get_tree().create_timer(duration, true, false, true).timeout

func hitstop(duration: float):
	Engine.time_scale = 0.0
	await wait(duration)
	Engine.time_scale = 1.0

func format_time(time: float) -> String:
	var minutes = int(time) / 60
	var seconds = fmod(time, 60)
	return "%d:%05.2f" % [minutes, seconds]
