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
@onready var settings_option_stars: Node = $Settings/OptionStars

@onready var star_rot_dynamics: DynamicsSolver = Dynamics.create_dynamics(4.0, 0.4, 2.0)

var target_rot = 0.0
var select_index = 0
var selector_target_y = 0.0
var original_selector_width
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

	if Input.is_action_just_pressed("dash"):
		if state == MenuState.SETTINGS:
			change_state(MenuState.MAIN)

func change_state(new_state: MenuState):
	state = new_state
	set_index(0)
	match state:
		MenuState.MAIN:
			camera_target.position = Vector2(160, 120)
		MenuState.SETTINGS:
			camera_target.position = Vector2(160 - 320, 120)

func main_state(dt: float):
	option_selector.global_position.y = lerp(option_selector.global_position.y, selector_target_y, 25.0 * dt)
	option_selector.scale.x = lerp(option_selector.scale.x, 1.0, 10.0 * dt)

	if Input.is_action_just_pressed("right") or Input.is_action_just_pressed("down"):
		set_index(select_index + 1)
	if Input.is_action_just_pressed("left") or Input.is_action_just_pressed("up"):
		set_index(select_index - 1)
	if Input.is_action_just_pressed("jump"):
		match select_index:
			0: RoomManager.change_room("levels/test_level_2")
			1: change_state(MenuState.SETTINGS)
			2: get_tree().quit()

func settings_state(dt: float):
	settings_option_selector.global_position.y = lerp(settings_option_selector.global_position.y, selector_target_y + 21, 25.0 * dt)
	settings_option_selector.scale.x = lerp(settings_option_selector.scale.x, 1.0, 10.0 * dt)

	if Input.is_action_just_pressed("down"):
		set_index(select_index + 1, -1)
	if Input.is_action_just_pressed("up"):
		set_index(select_index - 1, -1)
	if Input.is_action_just_pressed("jump") and select_index == 3:
		change_state(MenuState.MAIN)

func set_index(new_value: int, direction: int = 1):
	var prev_index = select_index
	var options = self.options if state == MenuState.MAIN else settings_options
	select_index = wrapi(new_value, 0, options.get_child_count())
	selector_target_y = options.get_child(select_index).global_position.y + options.get_child(select_index).size.y - 21.0
	target_rot += 45.0 * direction * sign(new_value - prev_index)
	selector_ping_timer.start()

func _on_selector_ping_timer_timeout() -> void:
	option_selector.scale.x = 1.05
	settings_option_selector.scale.x = 1.05

func _on_shooting_star_timer_timeout() -> void:
	var shooting_star = shooting_star_scene.instantiate() as ShootingStar
	# shooting_star.position = Vector2(-16, randf_range(20.0, 220.0))
	shooting_star.position = Vector2(randf_range(-280.0, 280.0), -16)
	# shooting_star.dir = Vector2.RIGHT.rotated(randf_range(-PI/2, PI/2))
	shooting_star.dir = Vector2(1, 1).rotated(randf_range(-PI/4, PI/4)).normalized()
	shooting_star.z_index = -8 if randf() > 0.5 else -15
	add_child(shooting_star)
	shooting_star_timer.start(randf_range(1.0, 2.0))
