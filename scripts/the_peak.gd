class_name ThePeak extends Level

const shooting_star_scene = preload("res://scenes/particles/shooting-star/shooting_star.tscn")
const fake_star_scene = preload("res://scenes/fake-star/fake_star.tscn")

@export var target_final_y = -1674.0

@onready var final_camera_target: Node2D = $FinalCameraTarget
@onready var shooting_star_timer: Timer = $ShootingStarTimer
@onready var give_star_timer: Timer = $GiveStarTimer

func _on_win_area_body_entered(body: Node2D) -> void:
	if not body is Player: return

	player.stop_everything()

	camera.follow = final_camera_target

	time_label.visible = false
	stars_hud.visible = false

	SaveManager.save_level(level_name, stars_collected, time)
	# unlock the next level if the player beat the next one
	if SaveManager.data["next_level"] == SaveManager.data["current_level"]:
		SaveManager.data["next_level"] += 1
		SaveManager.save_game()

	await Clock.wait(1.2)

	# start giving stars
	give_star_timer.start()

	await Clock.wait(5.0)

	camera.position_smoothing_speed = 2.0
	final_camera_target.position.y = target_final_y

func _on_shooting_star_timer_timeout() -> void:
	var shooting_star = shooting_star_scene.instantiate() as ShootingStar
	shooting_star.position = Vector2(randf_range(1936, 2112), -1984.0)
	shooting_star.dir = Vector2(1, 1).rotated(randf_range(-PI/4, PI/4)).normalized()
	add_child(shooting_star)
	shooting_star_timer.start(randf_range(1.0, 2.0))

func _on_give_star_timer_timeout():
	# spawn a fake star
	var fake_star = fake_star_scene.instantiate() as FakeStar
	fake_star.position = player.position
	add_child(fake_star)
	give_star_timer.wait_time = randf_range(0.8, 1.1)
