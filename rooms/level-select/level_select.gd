class_name LevelSelect extends Room

const shooting_star_scene = preload("res://scenes/particles/shooting-star/shooting_star.tscn")

@onready var shooting_star_timer: Timer = $ShootingStarTimer
@onready var camera_target: Node2D = $CameraTarget
@onready var stars: Node2D = $Stars
@onready var arrow_3d: Node3D = $Arrow/SubViewport/Arrow3D
@onready var arrow: SubViewportContainer = $Arrow
@onready var stars_icon: Star2D = $CanvasLayer/StarsIcon
@onready var level_num: TextureRect = $CanvasLayer/LevelNum
@onready var level_time_label: RichTextLabel = $CanvasLayer/TimeLabel
@onready var level_stars_label: RichTextLabel = $CanvasLayer/LevelStarsLabel
@onready var stars_label: RichTextLabel = $CanvasLayer/StarsLabel
@onready var bird_follow: PathFollow2D = $BirdFollow
@onready var bird_jump_path: Path2D = $JumpPath
@onready var bird_smooth_path: Path2D = $SmoothPath
@onready var bird_anchor: Node2D = $BirdFollow/BirdAnchor
@onready var bird: Sprite2D = $BirdFollow/BirdAnchor/Bird
@onready var star_path_line: Line2D = $Line2D

@onready var bird_dynamics: DynamicsSolverVector = Dynamics.create_dynamics_vector(2.0, 0.5, 2.0);

var select_index = 0
var arrow_target_pos = Vector2.ZERO
var bird_path_progress_target = 0.0
var tween: Tween
var target_bird_scale = Vector2.ONE
var can_move = true

func _ready() -> void:
	bird_follow.reparent(bird_jump_path)
	set_index(SaveManager.data["current_level"])
	stars_label.text = str(int(SaveManager.data["total_stars"]))
	for i in range(stars.get_child_count()):
		var star = stars.get_child(i) as LevelSelectStar
		star.set_locked(i > SaveManager.data["next_level"])
	set_index(select_index)

func _process(dt: float) -> void:
	camera_target.position = stars.get_child(select_index).position + Vector2(60, 0)
	arrow_3d.rotation_degrees.z += dt * 100
	arrow.position = arrow.position.lerp(arrow_target_pos + Vector2(sin(Clock.time * 4.0) * 2, 0), dt * 20)
	stars_icon.rotation_degrees += dt * 40.0
	bird.scale = bird_dynamics.update(target_bird_scale);

	if not can_move:
		return

	if Input.is_action_just_pressed("up"):
		set_index(select_index + 1)
	if Input.is_action_just_pressed("down"):
		set_index(select_index - 1)
	if Input.is_action_just_pressed("jump"):
		if (stars.get_child(select_index) as LevelSelectStar).is_locked:
			RoomManager.current_room.camera.shake(0.1, 4)
			AudioManager.play_sound(AudioManager.locked, 0.2)
			return

		AudioManager.play_sound(AudioManager.enter_level)
		can_move = false
		SaveManager.data["current_level"] = select_index
		SaveManager.save_game()

		if tween: tween.kill()
		target_bird_scale = Vector2.ONE
		tween = get_tree().create_tween().set_parallel(true)
		tween.tween_property(bird_anchor, "rotation_degrees", 400.0, 0.5).set_trans(Tween.TRANS_LINEAR)
		tween.tween_property(bird_anchor, "position:y", bird.position.y - 40, 0.4).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
		tween.tween_property(bird_anchor, "position:y", bird.position.y + 20, 0.45).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_IN).set_delay(0.15)
		tween.tween_property(bird_anchor, "scale", Vector2.ZERO, 0.15).set_delay(0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

		await Clock.wait(0.4)
		var star = stars.get_child(select_index) as LevelSelectStar
		RoomManager.change_room("levels/" + star.level_path)
	if Input.is_action_just_pressed("dash"):
		RoomManager.change_room("main-menu/main_menu")

func set_index(new_index: int) -> void:
	var prev_index = select_index
	select_index = clampi(new_index, 0, stars.get_child_count() - 1)
	var current_star = stars.get_child(select_index) as LevelSelectStar
	PaletteManager.set_palette(current_star.current_palette)
	arrow_target_pos = current_star.position + Vector2(-60, -12)
	level_num.texture = Globals.number_textures[select_index + 1]

	var dir = sign(select_index - prev_index)
	if dir != 0:
		AudioManager.play_sound(AudioManager.select, 0.2)
		if tween: tween.kill()
		tween = get_tree().create_tween().set_parallel(true)
		bird.flip_h = bird.global_position.x > current_star.global_position.x
		if dir > 0:
			bird_follow.reparent(bird_jump_path)
			bird_follow.progress_ratio = (select_index - 1) / 3.0
			tween.tween_callback(func(): bird_dynamics.set_value(Vector2.ONE + Vector2(-0.4, 0.4)))
			tween.tween_property(bird_follow, "progress_ratio", select_index / 3.0 - 0.0001, 0.65).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
			tween.tween_callback(func(): bird_dynamics.set_value(Vector2.ONE + Vector2(0.6, -0.6))).set_delay(0.3)
		if dir < 0:
			bird_follow.reparent(bird_smooth_path)
			bird_follow.progress_ratio = (select_index + 1) / 3.0
			tween.tween_property(bird_follow, "progress_ratio", select_index / 3.0, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	var level_data = SaveManager.get_level_data(current_star.level_name)
	if level_data == null:
		level_time_label.text = "--:--.--"
		level_stars_label.text = "0/5"
	else:
		level_stars_label.text = str(level_data["stars"]).split(".")[0] + "/5"
		if level_data["time"] != null:
			level_time_label.text = Clock.format_time(level_data["time"])
		else:
			level_time_label.text = "--:--.--"


	for i in range(stars.get_child_count()):
		var star = stars.get_child(i) as LevelSelectStar
		star.set_selected(i == select_index)

func _on_shooting_star_timer_timeout() -> void:
	var shooting_star = shooting_star_scene.instantiate() as ShootingStar
	shooting_star.position = Vector2(randf_range(20.0, 300.0), -16)
	shooting_star.dir = Vector2(1, 1).rotated(randf_range(-PI/4, PI/4)).normalized()
	shooting_star.z_index = -8 if randf() > 0.5 else -15
	add_child(shooting_star)
	shooting_star_timer.start(randf_range(1.0, 2.0))
