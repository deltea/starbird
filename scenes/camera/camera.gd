class_name Camera extends Camera2D

@export var follow: Node2D
@export var rotation_speed = 5.0
@export var impact_rotation = 3.0
@export var shake_damping_speed = 2.0
@export var lookahead = 16.0

@onready var rot_dynamics: DynamicsSolver = Dynamics.create_dynamics(rotation_speed, 0.8, 10.0)

var shake_duration = 0
var shake_magnitude = 0
var original_pos = Vector2.ZERO

func _enter_tree() -> void:
	RoomManager.current_room.camera = self

func _ready() -> void:
	original_pos = offset

func _process(dt: float) -> void:
	rotation_degrees = rot_dynamics.update(0.0)

	global_position = follow.global_position
	if follow is LevelCameraTarget:
		global_position += Vector2(RoomManager.current_room.player.dir * lookahead, 0)

	offset = original_pos
	if shake_duration > 0:
		offset += Vector2.from_angle(randf_range(0, PI*2)) * shake_magnitude
		shake_duration -= dt * shake_damping_speed
	else:
		shake_duration = 0

func shake(duration: float, magnitude: float):
	shake_duration = duration
	shake_magnitude = magnitude

func impact(dir: float = 0):
	if dir == 0:
		rot_dynamics.set_value((1 if randf() > 0.5 else -1) * impact_rotation)
	else:
		rot_dynamics.set_value(impact_rotation * dir)
