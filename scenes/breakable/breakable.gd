class_name Breakable extends StaticBody2D

func on_break():
	$CollisionShape.set_deferred("disabled", true)
	await Clock.wait(0.05)
	queue_free()
