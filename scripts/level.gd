class_name Level extends Room

@export var level_name = "level"

@onready var time_label: RichTextLabel = $CanvasLayer/TimeLabel
@onready var canvas: CanvasLayer = $CanvasLayer
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

@onready var pause_canvas: CanvasLayer = $PauseLayer
@onready var pause_options: VBoxContainer = $PauseLayer/VBoxContainer
@onready var pause_option_selector: ColorRect = $PauseLayer/OptionSelector

@onready var star_scale_dynamics: DynamicsSolver = Dynamics.create_dynamics(4.0, 1, 2.0)

var player: Player

var is_completed = false
var is_started = false
var countdown_scale_target = Vector2.ONE
var countdown_rot_target = 360.0
var stars_collected = 0
var is_complete_animation_done =  false
var time = 0.0
var secret_found = false
var is_game_paused = false
var pause_selection_index = 0

func _ready() -> void:
	super._ready()

	get_tree().paused = true
	player.can_move = false

	complete_canvas.visible = false
	canvas.visible = true
	pause_canvas.visible = false
	time_label.visible = false
	RoomManager.current_room.camera.freeze = true

	show_countdown()

func _process(dt: float) -> void:
	countdown.scale = countdown_scale_dynamics.update(countdown_scale_target)
	countdown_texture.rotation_degrees = countdown_rot_dynamics.update(countdown_rot_target)
	countdown_background.rotation_degrees = Clock.time * 200.0
	time_label.text = Clock.format_time(time)
	pause_option_selector.position.y = lerp(pause_option_selector.position.y, pause_options.get_child(pause_selection_index).position.y - 3, dt * 35.0)

	for star in stars_hud.get_children():
		star.rotation_degrees += dt * 40.0

	if not is_completed and is_started and not is_game_paused:
		time += dt

	if is_complete_animation_done:
		complete_star.rotation_degrees += dt * 40.0
		complete_star.scale = star_scale_dynamics.update(1) * Vector2.ONE

		if Input.is_action_just_pressed("jump") or Input.is_action_just_pressed("dash"):
			RoomManager.change_room("level-select/level_select")

	if Input.is_action_just_pressed("esc") and not is_complete_animation_done and is_started:
		toggle_pause_game()

	if is_game_paused:
		if Input.is_action_just_pressed("dash"):
			toggle_pause_game()
		if Input.is_action_just_pressed("down"):
			pause_selection_index = (pause_selection_index + 1) % pause_options.get_child_count()
		if Input.is_action_just_pressed("up"):
			pause_selection_index = (pause_selection_index - 1) % pause_options.get_child_count()
		if Input.is_action_just_pressed("jump"):
			match pause_selection_index:
				0: toggle_pause_game()
				1: RoomManager.reload()
				2: RoomManager.change_room("level-select/level_select")

func toggle_pause_game():
	get_tree().paused = not get_tree().paused
	pause_canvas.visible = get_tree().paused
	is_game_paused = get_tree().paused
	pause_selection_index = 0

func show_countdown():
	countdown_scale_dynamics.set_value(Vector2.ONE * 0.2)
	countdown_rot_dynamics.set_value(0)
	countdown_rot_target = 360.0
	countdown_texture.texture = Globals.number_textures[3]
	AudioManager.play_sound(AudioManager.countdown_blip)

	await Clock.wait(0.7)
	countdown_scale_dynamics.set_value(Vector2.ONE * 0.2)
	countdown_rot_dynamics.set_value(0)
	countdown_rot_target = 360.0
	countdown_texture.texture = Globals.number_textures[2]
	AudioManager.play_sound(AudioManager.countdown_blip)

	await Clock.wait(0.6)
	countdown_scale_dynamics.set_value(Vector2.ONE * 0.2)
	countdown_rot_dynamics.set_value(0)
	countdown_rot_target = 360.0
	countdown_texture.texture = Globals.number_textures[1]
	AudioManager.play_sound(AudioManager.countdown_blip)

	await Clock.wait(0.6)
	countdown_scale_dynamics.set_value(Vector2.ONE * 0.2)
	countdown_rot_dynamics.set_value(0)
	countdown_rot_target = 360.0
	countdown_texture.texture = Globals.go_texture
	AudioManager.play_sound(AudioManager.countdown_start)
	await Clock.wait(0.4)
	get_tree().paused = false
	player.can_move = true

	await Clock.wait(0.4)
	countdown_scale_target = Vector2.ZERO
	await Clock.wait(0.1)

	countdown.visible = false
	time_label.visible = true
	is_started = true
	RoomManager.current_room.camera.freeze = false
	RoomManager.current_room.player.process_mode = ProcessMode.PROCESS_MODE_PAUSABLE

func complete():
	is_completed = true
	await Clock.wait(1.0)

	SaveManager.save_level(level_name, stars_collected, time)
	# unlock the next level if the player beat the next one
	if SaveManager.data["next_level"] == SaveManager.data["current_level"]:
		SaveManager.data["next_level"] += 1
		SaveManager.save_game()

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
	is_complete_animation_done =  true

func get_node_screen_position(node: Node2D) -> Vector2:
	var viewport = node.get_viewport()
	var global_pos = node.global_position
	var canvas_transform = viewport.get_canvas_transform()
	var screen_position = canvas_transform * global_pos
	return screen_position

func get_rank(final_time: float, stars: int) -> String:
	var score = 0
	if final_time < 40.0:
		score += 3
	elif final_time < 80.0:
		score += 2
	elif final_time < 120.0:
		score += 1

	score += ceil(stars * 0.3)

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
	star.top_level = true
	star.call_deferred("reparent", stars_hud)

	var index = star.get_index()

	var placeholder = Node.new()
	star.get_parent().add_child(placeholder)
	star.get_parent().move_child(placeholder, star.get_index())

	star.global_position = get_node_screen_position(star)
	star.target_pos = stars_hud.get_child(index).global_position

func _on_star_ping_timer_timeout() -> void:
	star_scale_dynamics.set_value(1.1)

func play_sound(sound: AudioStream, randomness: float = 0):
	AudioManager.play_sound(sound, randomness)
