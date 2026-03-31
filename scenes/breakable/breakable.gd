class_name Breakable extends StaticBody2D

@onready var quarters: Node2D = $Quarters
@onready var collider: CollisionShape2D = $CollisionShape
@onready var sprite: Sprite2D = $Sprite

func on_break():
	AudioManager.play_sound(AudioManager.breakable, 0.2)

	sprite.visible = false
	quarters.visible = true

	RoomManager.current_room.camera.impact()
	RoomManager.current_room.camera.shake(0.1, 2.0)
	Clock.hitstop(0.05)
	collider.set_deferred("disabled", true)
	for q in quarters.get_children():
		var quarter = (q as BreakableQuarter)
		quarter.enabled = true
		quarter.constant_rot = randf_range(-360.0, 360.0)
		quarter.velocity = Vector2(randf_range(-100.0, 100.0), randf_range(-200.0, -100.0))

	await Clock.wait(2.0)
	queue_free()
