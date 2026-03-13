class_name Camera extends RigidBody2D

@export var follow: Node2D
@export var rotation_speed = 5.0
@export var impact_rotation = 5.0
@export var shake_damping_speed = 2.0
@export var follow_speed = 10.0
@export var camera_follow_speed = 10.0

@onready var cam: Camera2D = $Camera
@onready var rot_dynamics: DynamicsSolver = Dynamics.create_dynamics(rotation_speed, 0.8, 10.0)
@onready var agent: NavigationAgent2D = $NavigationAgent

var shake_duration = 0
var shake_magnitude = 0
var original_pos = Vector2.ZERO
var target_pos = Vector2.ZERO

func _enter_tree() -> void:
	RoomManager.current_room.camera = self

func _ready() -> void:
	original_pos = cam.offset
	target_pos = global_position

func _process(dt: float) -> void:
	cam.rotation_degrees = rot_dynamics.update(0.0)
	cam.global_position = cam.global_position.lerp(global_position, camera_follow_speed * dt)

	if shake_duration > 0:
		cam.offset = original_pos + Vector2.from_angle(randf_range(0, PI*2)) * shake_magnitude
		shake_duration -= dt * shake_damping_speed
	else:
		shake_duration = 0
		cam.offset = original_pos

func _physics_process(_dt: float) -> void:
	agent.target_position = follow.global_position

	if NavigationServer2D.map_get_iteration_id(agent.get_navigation_map()) == 0:
		return
	if agent.is_navigation_finished():
		return

	var desired_agent_pos = agent.get_next_path_position()
	apply_central_force(((desired_agent_pos - global_position) * follow_speed).limit_length(1200))

func shake(duration: float, magnitude: float):
	shake_duration = duration
	shake_magnitude = magnitude

func impact(dir: float = 0):
	if dir == 0:
		rot_dynamics.set_value((1 if randf() > 0.5 else -1) * impact_rotation)
	else:
		rot_dynamics.set_value(impact_rotation * dir)
