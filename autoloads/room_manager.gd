extends CanvasLayer

@onready var player: AnimationPlayer = $AnimationPlayer

var current_room: Room
var is_transitioning = false

func _ready() -> void:
	player.play("transition")

func change_room(room: String):
	if is_transitioning:
		printerr("already transitioning")
		return

	player.play_backwards("transition")
	is_transitioning = true
	await Clock.wait(player.current_animation_length)

	var path = "res://rooms/" + room + ".tscn"
	if !ResourceLoader.exists(path):
		printerr("room not found: " + path)
		return

	var scene = load(path)

	await Clock.wait(player.current_animation_length)
	is_transitioning = false
	player.play("transition")

	get_tree().paused = false
	get_tree().change_scene_to_packed(scene)
