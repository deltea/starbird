class_name MainMenu extends Room

enum MenuState { MAIN, SETTINGS }

const shooting_star_scene = preload("res://scenes/particles/shooting-star/shooting_star.tscn")

@onready var big_star: Star2D = $BigStar
@onready var trailing_star: Star2D = $BigStar/TrailingStar
@onready var selector_ping_timer: Timer = $SelectorPingTimer
@onready var shooting_star_timer: Timer = $ShootingStarTimer
@onready var camera_target: Node2D = $CameraTarget

# main menu stuff
@onready var title_star: Star2D = $Main/Title/Star
@onready var option_selector: NinePatchRect = $Main/OptionSelector
@onready var options: VBoxContainer = $Main/Options

# settings stuff
@onready var settings_option_selector: NinePatchRect = $Settings/OptionSelector
@onready var settings_options: VBoxContainer = $Settings/Options
@onready var settings_option_stars: Node2D = $Settings/OptionStars

@onready var star_rot_dynamics: DynamicsSolver = Dynamics.create_dynamics(4.0, 0.4, 2.0)

var target_rot = 0.0
var select_index = 0
var selector_target_y = 0.0
var original_selector_width = 0.0
var state = MenuState.MAIN

func _ready() -> void:
	selector_target_y = option_selector.position.y
	original_selector_width = option_selector.size.x

func _process(dt: float) -> void:
	big_star.rotation_degrees = star_rot_dynamics.update(target_rot)
	trailing_star.rotation_degrees = lerp(trailing_star.rotation_degrees, big_star.rotation_degrees + 12.0, 10.0 * dt)
	trailing_star.position = big_star.position
	title_star.rotation_degrees += 160.0 * dt

	match state:
		MenuState.MAIN: main_state(dt)
		MenuState.SETTINGS: settings_state(dt)

	if Input.is_action_just_pressed("jump"):
		match select_index:
			0: RoomManager.change_room("levels/test_level_2")
			1: change_state(MenuState.SETTINGS)
			2: get_tree().quit()
	if Input.is_action_just_pressed("dash"):
		if state == MenuState.SETTINGS:
			change_state(MenuState.MAIN)

func change_state(new_state: MenuState):
	state = new_state
	select_index = 0
	match state:
		MenuState.MAIN:
			camera_target.position = Vector2(160, 120)
		MenuState.SETTINGS:
			camera_target.position = Vector2(160 - 320, 120)

func main_state(dt: float):
	option_selector.position.y = lerp(option_selector.position.y, selector_target_y + select_index * 25.0, 25.0 * dt)
	option_selector.scale.x = lerp(option_selector.scale.x, 1.0, 10.0 * dt)

	if Input.is_action_just_pressed("right") or Input.is_action_just_pressed("down"):
		change_index(1)
	if Input.is_action_just_pressed("left") or Input.is_action_just_pressed("up"):
		change_index(-1)

func settings_state(dt: float):
	if Input.is_action_just_pressed("right") or Input.is_action_just_pressed("down"):
		change_index(1, -1)
	if Input.is_action_just_pressed("left") or Input.is_action_just_pressed("up"):
		change_index(-1, -1)

func change_index(delta: int, direction: int = 1):
	select_index = wrapi(select_index + delta, 0, options.get_child_count())
	target_rot += 45.0 * direction * delta
	selector_ping_timer.start()

func _on_selector_ping_timer_timeout() -> void:
	option_selector.scale.x = 1.05

func _on_shooting_star_timer_timeout() -> void:
	var shooting_star = shooting_star_scene.instantiate() as ShootingStar
	# shooting_star.position = Vector2(-16, randf_range(20.0, 220.0))
	shooting_star.position = Vector2(randf_range(-280.0, 280.0), -16)
	# shooting_star.dir = Vector2.RIGHT.rotated(randf_range(-PI/2, PI/2))
	shooting_star.dir = Vector2(1, 1).rotated(randf_range(-PI/4, PI/4)).normalized()
	shooting_star.z_index = -8 if randf() > 0.5 else -15
	add_child(shooting_star)
	shooting_star_timer.start(randf_range(1.0, 2.0))
