class_name LevelSelect extends Room

const shooting_star_scene = preload("res://scenes/particles/shooting-star/shooting_star.tscn")

@onready var shooting_star_timer: Timer = $ShootingStarTimer
@onready var camera_target: Node2D = $CameraTarget
@onready var stars: Node2D = $Stars
@onready var arrow_3d: Node3D = $Arrow/SubViewport/Arrow3D
@onready var arrow: SubViewportContainer = $Arrow
@onready var stars_icon: Star2D = $CanvasLayer/StarsIcon
@onready var level_num: TextureRect = $CanvasLayer/LevelNum

var select_index = 0
var arrow_target_pos = Vector2.ZERO

func _ready() -> void:
	set_index(0)

func _process(dt: float) -> void:
	camera_target.position = stars.get_child(select_index).position + Vector2(60, 0)
	arrow_3d.rotation_degrees.z += dt * 100
	arrow.position = arrow.position.lerp(arrow_target_pos + Vector2(sin(Clock.time * 4.0) * 2, 0), dt * 20)
	stars_icon.rotation_degrees += dt * 40.0

	if Input.is_action_just_pressed("up"):
		set_index(select_index + 1)
	if Input.is_action_just_pressed("down"):
		set_index(select_index - 1)
	if Input.is_action_just_pressed("jump"):
		var star = stars.get_child(select_index) as LevelSelectStar
		RoomManager.change_room("levels/" + star.level_path)
	if Input.is_action_just_pressed("dash"):
		RoomManager.change_room("main-menu/main_menu")

func set_index(new_index: int) -> void:
	select_index = clampi(new_index, 0, stars.get_child_count() - 1)
	PaletteManager.set_palette((stars.get_child(select_index) as LevelSelectStar).palette)
	arrow_target_pos = stars.get_child(select_index).position + Vector2(-60, -12)
	level_num.texture = Globals.number_textures[select_index + 1]

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
