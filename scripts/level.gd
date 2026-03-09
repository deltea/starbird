extends Room

const countdown_rot = 10.0

@onready var time_label: RichTextLabel = $CanvasLayer/TimeLabel
@onready var countdown: Control = $CanvasLayer/Countdown
@onready var countdown_label: Label = $CanvasLayer/Countdown/CountdownLabel
@onready var countdown_background: ColorRect = $CanvasLayer/Countdown/CountdownBackground
@onready var countdown_scale_dynamics: DynamicsSolverVector = Dynamics.create_dynamics_vector(3.0, 0.15, 10.0)
@onready var countdown_rot_dynamics: DynamicsSolver = Dynamics.create_dynamics(3.0, 0.5, 10.0)
@onready var stars_hud: Node2D = $CanvasLayer/Stars

@onready var complete_palette_filter: ColorRect = $CompleteCanvas/SubViewportContainer/SubViewport/PaletteFilter
@onready var complete_canvas: CanvasLayer = $CompleteCanvas
@onready var complete_player: AnimationPlayer = $CompleteCanvas/SubViewportContainer/SubViewport/AnimationPlayer
@onready var complete_star: Star2D = $CompleteCanvas/SubViewportContainer/SubViewport/Star2D
@onready var rank_text: TextureRect = $CompleteCanvas/SubViewportContainer/SubViewport/RankText
@onready var final_label: RichTextLabel = $CompleteCanvas/SubViewportContainer/SubViewport/FinalStatsValues

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
	PaletteFilter.set_color_palette(palette)
	complete_palette_filter.material.set_shader_parameter("palette_out", palette)

	get_tree().paused = true
	player.can_move = false

	show_countdown()

func _process(dt: float) -> void:
	countdown.scale = countdown_scale_dynamics.update(countdown_scale_target)
	countdown_label.rotation_degrees = countdown_rot_dynamics.update(countdown_rot_target)
	countdown_background.rotation_degrees = Clock.time * 200.0
	time_label.text = "[wave]%.2f[/wave]" % time

	for star in stars_hud.get_children():
		star.rotation_degrees += dt * 40.0

	if not is_completed and is_started:
		time += dt

	if is_complete_animation_done:
		complete_star.rotation_degrees += dt * 40.0
		complete_star.scale = star_scale_dynamics.update(1) * Vector2.ONE
		# rank_text.rotation_degrees = sin(Clock.time * 5.0) * 6.0
		# rank_text.scale = (1.0 + sin(Clock.time * 5.0) * 0.05) * Vector2.ONE

func show_countdown():
	countdown_scale_dynamics.set_value(Vector2.ONE * 0.2)
	countdown_rot_dynamics.set_value(countdown_rot)
	countdown_rot_target = 360.0 - countdown_rot
	countdown_label.text = "3"

	await Clock.wait(0.6)
	countdown_scale_dynamics.set_value(Vector2.ONE * 0.2)
	countdown_rot_dynamics.set_value(-countdown_rot)
	countdown_rot_target = 360.0 + countdown_rot
	countdown_label.text = "2"

	await Clock.wait(0.6)
	countdown_scale_dynamics.set_value(Vector2.ONE * 0.2)
	countdown_rot_dynamics.set_value(countdown_rot)
	countdown_rot_target = 360.0 - countdown_rot
	countdown_label.text = "1"

	await Clock.wait(0.6)
	countdown_scale_dynamics.set_value(Vector2.ONE * 0.2)
	countdown_rot_dynamics.set_value(-countdown_rot)
	countdown_rot_target = 360.0 + countdown_rot
	countdown_label.text = "GO!"

	await Clock.wait(0.4)
	get_tree().paused = false
	player.can_move = true
	is_started = true

	await Clock.wait(0.4)
	countdown_scale_target = Vector2.ZERO
	await Clock.wait(0.1)
	countdown.visible = false

func complete():
	is_completed = true
	await Clock.wait(1.0)

	PaletteFilter.set_brightness(0.25)
	complete_canvas.visible = true
	time_label.visible = false
	stars_hud.visible = false
	final_label.text = "[wave]%.2f\n%s\n%s/5" % [
		time,
		"found" if secret_found else "not found",
		stars_collected
	]

	complete_player.play("complete")
	await complete_player.animation_finished
	is_complete_animation_done = true

func get_node_screen_position(node: Node2D) -> Vector2:
	var viewport = node.get_viewport()
	var global_pos = node.global_position
	var canvas_transform = viewport.get_canvas_transform()
	var screen_position = canvas_transform * global_pos
	return screen_position

func collect_star(star: Collectable) -> void:
	stars_collected += 1
	# star.reparent(stars_hud)
	star.call_deferred("reparent", stars_hud)
	star.position = get_node_screen_position(star)
	star.target_pos = stars_hud.get_child(stars_collected - 1).position

func _on_star_ping_timer_timeout() -> void:
	star_scale_dynamics.set_value(1.1)
