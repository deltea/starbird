class_name LevelSelectStar extends Node2D

@export var level_name = ""
@export var level_path = ""
@export var palette: Texture2D
@export var locked_palette: Texture2D

@onready var scale_dynamics: DynamicsSolver = Dynamics.create_dynamics(5.0, 0.2, 2.0)
@onready var star: Polygon2D = $Star
@onready var background_star: Star2D = $Star/BackgroundStar
@onready var level_name_label: RichTextLabel = $Background/LevelNameLabel
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var is_selected = false
var is_locked = true
var current_palette: Texture2D

func _ready() -> void:
	level_name_label.text = "[wave amp=8]" + level_name

func set_selected(new_value: bool) -> void:
	var was_selected = is_selected
	is_selected = new_value
	if is_selected and not was_selected:
		animation_player.play("select")
	elif not is_selected and was_selected:
		animation_player.play_backwards("select")

func set_locked(new_value: bool) -> void:
	print("Setting locked to ", new_value, " for level ", level_name)
	is_locked = new_value
	current_palette = locked_palette if is_locked else palette
	level_name_label.text = "[wave amp=8]" + level_name if not is_locked else "[wave amp=8][color=#555]" + "locked"

func _process(dt: float) -> void:
	star.rotation_degrees += dt * (120 if is_selected else 20)
	background_star.rotation_degrees = -star.rotation_degrees * 2.0
	star.scale = scale_dynamics.update(1.5 if is_selected else 1.0) * Vector2.ONE
	background_star.scale = background_star.scale.lerp(Vector2.ONE if is_selected else Vector2.ZERO, dt * 10)
	self_modulate = Color("#fff") if is_selected else Color("#ddd")
