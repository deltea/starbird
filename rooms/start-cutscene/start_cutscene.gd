class_name StartCutscene extends Room

@export var lines: Array[String] = []

@onready var label: RichTextLabel = $DialogueLabel

var line_index: int = -1
var tween: Tween

func _ready() -> void:
	label.text = ""
	await Clock.wait(0.5)
	next_line()

func _process(dt: float) -> void:
	if Input.is_action_just_pressed("jump") or Input.is_action_just_pressed("dash"):
		next_line()

func next_line():
	line_index += 1
	if line_index >= lines.size():
		RoomManager.change_room("level-select/level_select")
		return

	label.text = lines[line_index]
	label.visible_ratio = 0
	if tween: tween.kill()
	tween = get_tree().create_tween()
	tween.tween_property(label, "visible_characters", len(lines[line_index]), 0.8)
