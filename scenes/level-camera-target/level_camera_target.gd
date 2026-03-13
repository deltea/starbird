class_name LevelCameraTarget extends RigidBody2D

@export var player: Player
@export var follow_speed = 10.0
@export var speed_limit = 1200

@onready var agent: NavigationAgent2D = $NavigationAgent

func _ready() -> void:
	agent.target_position = player.global_position

func _physics_process(_dt: float) -> void:
	agent.target_position = player.global_position

	if NavigationServer2D.map_get_iteration_id(agent.get_navigation_map()) == 0:
		return
	if agent.is_navigation_finished():
		return

	var desired_agent_pos = agent.get_next_path_position()
	linear_velocity = ((desired_agent_pos - global_position) * follow_speed).limit_length(speed_limit)
