extends Room

@export var level_name = "level"

@onready var time_label: RichTextLabel = $CanvasLayer/TimeLabel
@onready var countdown_canvas: CanvasLayer = $CanvasLayer
@onready var countdown: Control = $CanvasLayer/Countdown
@onready var countdown_texture: TextureRect = $CanvasLayer/Countdown/Countdown
@onready var countdown_background: ColorRect = $CanvasLayer/Countdown/CountdownBackground
@onready var countdown_scale_dynamics: DynamicsSolverVector = Dynamics.create_dynamics_vector(3.0, 0.15, 10.0)
@onready var countdown_rot_dynamics: DynamicsSolver = Dynamics.create_dynamics(3.0, 0.5, 10.0)
@onready var stars_hud: Node2D = $CanvasLayer/Stars

@onready var complete_canvas: CanvasLayer = $CompleteCanvas
@onready var complete_player: AnimationPlayer = $CompleteCanvas/AnimationPlayer
@onready var complete_star: Star2D = $CompleteCanvas/Star2D
@onready var rank_text: TextureRect = $CompleteCanvas/RankText
@onready var final_label: RichTextLabel = $CompleteCanvas/FinalStatsValues

@onready var star_scale_dynamics: DynamicsSolver = Dynamics.create_dynamics(4.0, 1, 2.0)

var player: Player

var is_completed = false
var is_started = false
var countdown_scale_target = Vector2.ONE
var countdown_rot_target = 360.0
var stars_collected = 0
var is_complete_animation_done = false
var time = 0.0
var secret_found = false

func _ready() -> void:
	super._ready()

	get_tree().paused = true
	player.can_move = false

	complete_canvas.visible = false
	countdown_canvas.visible = true
	time_label.visible = false

	show_countdown()

func _process(dt: float) -> void:
	countdown.scale = countdown_scale_dynamics.update(countdown_scale_target)
	countdown_texture.rotation_degrees = countdown_rot_dynamics.update(countdown_rot_target)
	countdown_background.rotation_degrees = Clock.time * 200.0
	time_label.text = Clock.format_time(time)

	for star in stars_hud.get_children():
		star.rotation_degrees += dt * 40.0

	if not is_completed and is_started:
		time += dt

	if is_complete_animation_done:
		complete_star.rotation_degrees += dt * 40.0
		complete_star.scale = star_scale_dynamics.update(1) * Vector2.ONE

		if Input.is_action_just_pressed("jump") or Input.is_action_just_pressed("dash"):
			RoomManager.change_room("level-select/level_select")

func show_countdown():
	countdown_scale_dynamics.set_value(Vector2.ONE * 0.2)
	countdown_rot_dynamics.set_value(0)
	countdown_rot_target = 360.0
	countdown_texture.texture = Globals.number_textures[3]

	await Clock.wait(0.7)
	countdown_scale_dynamics.set_value(Vector2.ONE * 0.2)
	countdown_rot_dynamics.set_value(0)
	countdown_rot_target = 360.0
	countdown_texture.texture = Globals.number_textures[2]

	await Clock.wait(0.6)
	countdown_scale_dynamics.set_value(Vector2.ONE * 0.2)
	countdown_rot_dynamics.set_value(0)
	countdown_rot_target = 360.0
	countdown_texture.texture = Globals.number_textures[1]

	await Clock.wait(0.6)
	countdown_scale_dynamics.set_value(Vector2.ONE * 0.2)
	countdown_rot_dynamics.set_value(0)
	countdown_rot_target = 360.0
	countdown_texture.texture = Globals.go_texture

	await Clock.wait(0.4)
	get_tree().paused = false
	player.can_move = true

	await Clock.wait(0.4)
	countdown_scale_target = Vector2.ZERO
	await Clock.wait(0.1)

	countdown.visible = false
	time_label.visible = true
	is_started = true

func complete():
	is_completed = true
	await Clock.wait(1.0)

	SaveManager.save_level(level_name, stars_collected, time)

	complete_canvas.visible = true
	time_label.visible = false
	stars_hud.visible = false
	final_label.text = "%s\n%s\n%s/5" % [
		Clock.format_time(time),
		"found" if secret_found else "not found",
		stars_collected
	]
	rank_text.texture = Globals.get("%s_rank_texture" % get_rank(time, stars_collected).to_lower())

	complete_player.play("complete")
	await complete_player.animation_finished
	is_complete_animation_done = true

func get_node_screen_position(node: Node2D) -> Vector2:
	var viewport = node.get_viewport()
	var global_pos = node.global_position
	var canvas_transform = viewport.get_canvas_transform()
	var screen_position = canvas_transform * global_pos
	return screen_position

func get_rank(final_time: float, stars: int) -> String:
	var score = 0
	if final_time < 30.0:
		score += 3
	elif final_time < 60.0:
		score += 2
	elif final_time < 90.0:
		score += 1

	score += ceil(stars * 0.5)

	if score >= 5:
		return "S"
	elif score >= 4:
		return "A"
	elif score >= 3:
		return "B"
	else:
		return "C"

func collect_star(star: Collectable) -> void:
	stars_collected += 1
	star.call_deferred("reparent", stars_hud)
	star.position = get_node_screen_position(star)
	star.target_pos = stars_hud.get_child(stars_collected - 1).position

func _on_star_ping_timer_timeout() -> void:
	star_scale_dynamics.set_value(1.1)
