class_name Camera extends Camera2D

@export var follow: Node2D
@export var bounds: Polygon2D
@export var rotation_speed = 5.0
@export var impact_rotation = 5.0
@export var shake_damping_speed = 2.0

@onready var rot_dynamics: DynamicsSolver = Dynamics.create_dynamics(rotation_speed, 0.8, 10.0)

var shake_duration = 0;
var shake_magnitude = 0;
var original_pos = Vector2.ZERO;
var target_zoom = Vector2.ONE
var target_pos

func _enter_tree() -> void:
	RoomManager.current_room.camera = self

func _ready() -> void:
	original_pos = offset
	target_pos = global_position

	reset_smoothing()

func _process(dt: float) -> void:
	rotation_degrees = rot_dynamics.update(0.0)

	if follow:
		target_pos = follow.global_position
		# global_position = target_pos

	target_pos = bounds.get_constrained_point(target_pos - bounds.global_position) + bounds.global_position
	global_position = global_position.lerp(target_pos, 10.0 * dt)

	if shake_duration > 0:
		offset = original_pos + Vector2.from_angle(randf_range(0, PI*2)) * shake_magnitude
		shake_duration -= dt * shake_damping_speed
	else:
		shake_duration = 0
		offset = original_pos

func shake(duration: float, magnitude: float):
	shake_duration = duration
	shake_magnitude = magnitude

func impact(dir: float = 0):
	if dir == 0:
		rot_dynamics.set_value((1 if randf() > 0.5 else -1) * impact_rotation)
	else:
		rot_dynamics.set_value(impact_rotation * dir)
